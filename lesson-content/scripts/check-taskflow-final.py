#!/usr/bin/env python3

"""Prüft den veröffentlichten Abschlussstand und seine technischen Nachweise."""

import json
import subprocess
import sys
import tempfile
from pathlib import Path


class CheckFailed(Exception):
    pass


def require(condition, message):
    if not condition:
        raise CheckFailed(message)


def git(repo, *args, allowed=(0,)):
    result = subprocess.run(
        ["git", "-C", str(repo), *args], capture_output=True, text=True, timeout=15
    )
    require(result.returncode in allowed, result.stderr.strip() or "Eine benötigte Git-Angabe fehlt.")
    return result.stdout.strip()


def ancestor(repo, earlier, later):
    result = subprocess.run(
        ["git", "-C", str(repo), "merge-base", "--is-ancestor", earlier, later],
        capture_output=True, text=True, timeout=15,
    )
    return result.returncode == 0


def read_review(path):
    require(path.is_file(), f"Der dokumentierte Review fehlt: {path.name}")
    fields = dict(
        line.split(": ", 1)
        for line in path.read_text(encoding="utf-8").splitlines()
        if ": " in line
    )
    require(fields.get("Quelle") == "feature/version im Teamrepository", "Der Review nennt nicht den vorgesehenen Quellbranch.")
    require(fields.get("Ziel") == "main im Teamrepository", "Der Review nennt nicht den vorgesehenen Zielbranch.")
    require(fields.get("Rückmeldung", "").strip(), "Eine begründete Review-Rückmeldung fehlt.")
    return fields


def check(root):
    require((root / ".taskflow-final").is_file(), "Der Ordner ist kein vorbereiteter Abschluss-Challenge-Stand.")
    state = json.loads((root / ".challenge-state.json").read_text(encoding="utf-8"))
    own = root / "mein-taskflow"
    team = root / "team.git"
    require((own / ".git").is_dir(), "Die geklonte Arbeitskopie mein-taskflow fehlt.")
    require(not git(own, "status", "--porcelain"), "Die Arbeitskopie hat noch offene Änderungen.")
    require(not (own / ".git/MERGE_HEAD").exists() and
            not (own / ".git/rebase-merge").exists() and
            not (own / ".git/rebase-apply").exists(), "Eine Integration läuft noch.")
    require(git(own, "symbolic-ref", "--quiet", "--short", "HEAD") == "main", "Wechseln Sie für die Abschlusskontrolle zum Hauptzweig.")
    target = git(team, "rev-parse", "refs/heads/main")
    source = git(team, "rev-parse", "refs/heads/feature/version")
    require(target == source == git(own, "rev-parse", "HEAD"), "Arbeitskopf, geteilter Versionsbeitrag und Teamhauptzweig sind noch nicht auf demselben fertigen Stand.")
    require(git(own, "rev-parse", "refs/heads/feature/version") == source, "Der eigene Versionsbranch stimmt nicht mit dem veröffentlichten Stand überein.")
    require(git(own, "rev-parse", "refs/remotes/origin/main") == target, "Ihr bekannter Teamhauptzweig ist noch nicht aktuell.")
    for branch in ["bugfix/dokumentation", "feature/version"]:
        published = git(team, "rev-parse", f"refs/heads/{branch}")
        require(ancestor(team, published, target), f"Der geteilte Branch {branch} wurde noch nicht vollständig aufgenommen.")
        require(git(own, "config", f"branch.{branch}.remote") == "origin" and
                git(own, "config", f"branch.{branch}.merge") == f"refs/heads/{branch}",
                f"Die Upstream-Zuordnung für {branch} fehlt.")
    require(ancestor(team, state["team_start"], target), "Die ursprünglichen geteilten Teamcommits müssen erhalten bleiben.")
    require(ancestor(team, state["wrong_changelog"], target), "Der ursprüngliche fehlerhafte Changelog-Commit darf nicht aus der Teamhistorie ersetzt werden.")
    require(state.get("sam_commit"), "Sams Parallelbeitrag wurde noch nicht bereitgestellt.")
    require(ancestor(team, state["sam_commit"], target), "Sams veröffentlichter Beitrag fehlt unter seiner bisherigen Kennung im Hauptzweig.")
    first = read_review(root / "review-erstpruefung.txt")
    final = read_review(root / "review.txt")
    require(first.get("Entscheidung") == "Überarbeitung erforderlich", "Die Erstprüfung soll eine begründete Überarbeitung dokumentieren.")
    require(final.get("Entscheidung") == "freigegeben", "Für den Abschluss fehlt Miras dokumentierte Freigabe.")
    require(first.get("Zielcommit") == final.get("Zielcommit") == state["team_start"], "Die Prüfanfragen müssen vor der Änderung des Teamhauptzweigs erfolgen.")
    require(final.get("Quellcommit") == source, "Die Freigabe gehört nicht zum tatsächlich aufgenommenen Versionsbeitrag.")
    first_source = first.get("Quellcommit", "")
    require(first_source != source and ancestor(team, first_source, source), "Die überarbeiteten Beiträge müssen auf dem zuerst geteilten Stand aufbauen.")
    git(team, "diff", "--check", state["team_start"], source)

    # Die Laufzeitprüfung verwendet Dateien aus dem veröffentlichten Commit.
    # Eine ungeteilte Datei im Arbeitsverzeichnis kann sie nicht beeinflussen.
    with tempfile.TemporaryDirectory(prefix="taskflow-final-check-") as tmp:
        snapshot = Path(tmp)
        files = ["taskflow.py", "aufgaben.json", "version.txt", "README.md", "CHANGELOG.md", "TEAM.md"]
        for filename in files:
            blob = subprocess.run(
                ["git", "-C", str(team), "show", f"{source}:{filename}"],
                capture_output=True, timeout=15,
            )
            require(blob.returncode == 0, f"Die veröffentlichte Datei {filename} fehlt.")
            (snapshot / filename).write_bytes(blob.stdout)
        require((snapshot / "version.txt").read_text(encoding="utf-8").strip() == state["version"], "version.txt enthält nicht die geforderte Version 0.2.0.")
        before = (snapshot / "aufgaben.json").read_bytes()
        tasks = json.loads(before)
        require(tasks == [
            {"text": "Übungsblatt Programmierung bearbeiten", "erledigt": False},
            {"text": "Lerntermin vereinbaren", "erledigt": True},
        ], "Die vorbereiteten offenen und erledigten Beispielaufgaben sollen erhalten bleiben.")
        version_run = subprocess.run([sys.executable, "taskflow.py", "--version"], cwd=snapshot, capture_output=True, text=True, timeout=10)
        require(version_run.returncode == 0 and version_run.stdout.strip() == "TaskFlow 0.2.0", "Die veröffentlichte Programmoption --version liefert noch nicht TaskFlow 0.2.0.")
        normal_run = subprocess.run([sys.executable, "taskflow.py"], cwd=snapshot, capture_output=True, text=True, timeout=10)
        require(normal_run.returncode == 0 and normal_run.stdout.splitlines() == [
            "Offen: Übungsblatt Programmierung bearbeiten", "Erledigt: Lerntermin vereinbaren"
        ], "Der veröffentlichte normale Programmaufruf muss beide Beispielaufgaben anzeigen.")
        require(before == (snapshot / "aufgaben.json").read_bytes(), "Die Programmaufrufe dürfen die gespeicherten Beispielaufgaben nicht verändern.")
    print("Technische Abschlusskontrolle erfolgreich.")
    print(f"Geprüfter Teamhauptzweig: {target}")
    print(f"Aufgenommener Quellbranch: feature/version bei {source}")
    print(f"Ursprünglicher Teamstand erhalten: {state['team_start']}")
    print(f"Sams Beitrag erhalten: {state['sam_commit']}")
    print("Versionsausgabe und normale Aufgabenanzeige aus dem veröffentlichten Commit geprüft.")
    print("Die fachliche Dokumentationsprüfung und Ihre Reflexion werden separat anhand der Aufgaben beurteilt.")


if __name__ == "__main__":
    try:
        require(len(sys.argv) == 2, "Verwendung: python3 check-taskflow-final.py <challenge-ordner>")
        check(Path(sys.argv[1]).resolve())
    except (CheckFailed, OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"Abschlusskontrolle noch nicht erfüllt: {error}")
        raise SystemExit(1)
