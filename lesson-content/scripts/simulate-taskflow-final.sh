#!/bin/bash

# Veröffentlicht Sams Parallelbeitrag nach der ersten dokumentierten Prüfanfrage.
set -euo pipefail
if [ "$#" -ne 1 ]; then
    echo "Verwendung: bash simulate-taskflow-final.sh <challenge-ordner>"
    exit 1
fi
wurzel="$(cd "$1" && pwd -P)"
if [ ! -f "$wurzel/.taskflow-final" ] || [ ! -f "$wurzel/.challenge-state.json" ]; then
    echo "Der Ordner ist kein vorbereiteter Abschluss-Challenge-Stand."
    exit 1
fi
if [ -f "$wurzel/.sam-final-done" ]; then
    echo "Sams Beitrag wurde bereits veröffentlicht. Es wurde nichts verändert."
    exit 0
fi
python3 - "$wurzel" <<'PY'
import json
import subprocess
import sys
from pathlib import Path
root = Path(sys.argv[1])
state = json.loads((root / ".challenge-state.json").read_text(encoding="utf-8"))
def rev(repo, ref):
    return subprocess.check_output(["git", "-C", str(repo), "rev-parse", "--verify", ref], text=True).strip()
report = root / "review-erstpruefung.txt"
if not report.is_file():
    raise SystemExit("Dokumentieren Sie zuerst die Erstprüfung und bewahren Sie deren Rückmeldung auf.")
fields = dict(line.split(": ", 1) for line in report.read_text(encoding="utf-8").splitlines() if ": " in line)
if fields.get("Entscheidung") != "Überarbeitung erforderlich":
    raise SystemExit("Die Erstprüfung soll den noch fehlenden gemeinsamen Wochenrückblick benennen.")
if fields.get("Quellcommit") != rev(root / "team.git", "refs/heads/feature/version"):
    raise SystemExit("Die Erstprüfung passt nicht zum veröffentlichten Versionsbeitrag.")
if fields.get("Zielcommit") != state["team_start"] or rev(root / "team.git", "main") != state["team_start"]:
    raise SystemExit("Der Teamhauptzweig wurde bereits verändert. Die erste Prüfanfrage muss vor der Aufnahme erfolgen.")
PY
samrepo="$wurzel/sam"
ausgang="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["team_start"])' "$wurzel/.challenge-state.json")"
if [ -n "$(git -C "$samrepo" status --porcelain)" ] || \
   [ "$(git -C "$samrepo" symbolic-ref --quiet --short HEAD)" != "main" ] || \
   [ "$(git -C "$samrepo" rev-parse HEAD)" != "$ausgang" ] || \
   [ "$(git -C "$samrepo" remote get-url origin)" != "../sam-team.git" ]; then
    echo "Sams Arbeitskopie wurde verändert. Ihre vorhandene Arbeit bleibt erhalten."
    exit 1
fi
git -C "$samrepo" switch -q -c docs/wochenrueckblick
cat > "$samrepo/README.md" <<'EOF'
# TaskFlow

TaskFlow verwaltet Lernaufgaben für das Studium.
Erledigte Aufgaben werden beim Wochenrückblick gemeinsam besprochen.
EOF
git -C "$samrepo" add README.md
git -C "$samrepo" commit -q -m "Erledigte Aufgaben im gemeinsamen Wochenrückblick besprechen"
git -C "$samrepo" push -q -u origin docs/wochenrueckblick
samstand="$(git -C "$samrepo" rev-parse HEAD)"
python3 - "$wurzel" "$samstand" <<'PY'
import json
import sys
from pathlib import Path
path = Path(sys.argv[1]) / ".challenge-state.json"
state = json.loads(path.read_text(encoding="utf-8"))
state["sam_commit"] = sys.argv[2]
path.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
PY
touch "$wurzel/.sam-final-done"
echo "Sams Beitrag liegt jetzt auf docs/wochenrueckblick in sam-team.git."
echo "Ihre Arbeitskopie und der Hauptzweig von team.git wurden nicht verändert."
