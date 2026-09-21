#!/bin/bash

# Erstellt einen unabhängigen Teamstand für die Abschluss-Challenge.
set -euo pipefail
ziel="${1:-taskflow-abschluss-challenge}"
if [ -e "$ziel" ] || [ -L "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/sam"
git init -q --bare -b main "$ziel/team.git"
git init -q --bare -b main "$ziel/sam-team.git"
(
    cd "$ziel/sam"
    git init -q -b main
    git config user.name "Sam Beispiel"
    git config user.email "sam@taskflow.example"
    git config core.editor nano
    git config merge.conflictStyle merge
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow verwaltet Lernaufgaben für das Studium.
Erledigte Aufgaben werden automatisch gelöscht.
EOF
    cat > taskflow.py <<'EOF'
import json
from argparse import ArgumentParser
from pathlib import Path


def main():
    parser = ArgumentParser(description="TaskFlow-Beispiel für den Git-Kurs")
    parser.parse_args()
    pfad = Path(__file__).with_name("aufgaben.json")
    aufgaben = json.loads(pfad.read_text(encoding="utf-8"))
    for aufgabe in aufgaben:
        status = "Erledigt" if aufgabe["erledigt"] else "Offen"
        print(f'{status}: {aufgabe["text"]}')


if __name__ == "__main__":
    main()
EOF
    cat > aufgaben.json <<'EOF'
[
  {"text": "Übungsblatt Programmierung bearbeiten", "erledigt": false},
  {"text": "Lerntermin vereinbaren", "erledigt": true}
]
EOF
    echo "0.1.0" > version.txt
    git add README.md taskflow.py aufgaben.json version.txt
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "TaskFlow-Beispiel mit zwei Lernaufgaben bereitstellen"
    cat > CHANGELOG.md <<'EOF'
# Änderungen

## 0.1.0
TaskFlow zeigt offene und erledigte Aufgaben an.
EOF
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Beiträge werden auf Arbeitsbranches vorbereitet und vor der Aufnahme geprüft.
Bereits geteilte Beiträge sollen mit ihren bisherigen Kennungen erhalten bleiben.
EOF
    git add CHANGELOG.md TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Änderungsübersicht und Prüfregel anlegen"
    echo "Die Option --version ist verfügbar." >> CHANGELOG.md
    git add CHANGELOG.md
    git -c user.name="Sam Beispiel" -c user.email="sam@taskflow.example" \
        commit -q -m "Versionsausgabe irrtümlich als verfügbar dokumentieren"
    git remote add origin ../sam-team.git
    git push -q -u origin main
    git push -q ../team.git main
)
ausgang="$(git -C "$ziel/team.git" rev-parse main)"
python3 - "$ziel" "$ausgang" <<'PY'
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
state = {"team_start": sys.argv[2], "wrong_changelog": sys.argv[2], "version": "0.2.0"}
(root / ".challenge-state.json").write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
PY
touch "$ziel/.taskflow-final" "$ziel/.taskflow-collaboration"
echo "Challenge-Teamstand erstellt: $ziel/team.git"
echo "Sams Austauschstelle: $ziel/sam-team.git"
echo "Ihre Arbeitskopie legen Sie mit dem ersten Auftrag selbst an."
