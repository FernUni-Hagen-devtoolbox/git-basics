#!/bin/bash

# Erstellt einen geteilten Beitrag, Sams darauf aufbauende Arbeit und einen Konflikt.
set -euo pipefail

ziel="${1:-taskflow-kollaboration-challenge}"
if [ -e "$ziel" ] || [ -L "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/mein-taskflow"
git init -q --bare -b main "$ziel/team.git"
(
    cd "$ziel/mein-taskflow"
    git init -q -b main
    git config user.name "Lea Beispiel"
    git config user.email "lea@beispiel.de"
    git config core.editor nano
    git config merge.conflictStyle merge
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow begleitet die wöchentliche Planung im Lernteam.
EOF
    git add README.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "TaskFlow für die Wochenplanung vorstellen"
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Geteilte Beiträge und darauf aufbauende Arbeit behalten ihre bisherigen Kennungen.
Mira prüft die fertige gemeinsame Lösung vor der Aufnahme in main.
EOF
    git add TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Prüfung geteilter Beiträge vereinbaren"
    cat > WOCHENABSCHLUSS.md <<'EOF'
# Wochenabschluss im Lernteam

Offene Aufgaben werden am Ende der Woche besprochen.
EOF
    git add WOCHENABSCHLUSS.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Besprechung offener Aufgaben einführen"
    git remote add origin ../team.git
    git push -q -u origin main
    git switch -q -c docs/wochenabschluss
    cat > WOCHENABSCHLUSS.md <<'EOF'
# Wochenabschluss im Lernteam

Offene Aufgaben werden am Freitag im Lernteam besprochen.
EOF
    git add WOCHENABSCHLUSS.md
    git commit -q -m "Besprechung offener Aufgaben am Freitag beschreiben"
    cat > REFLEXION.md <<'EOF'
# Rückblick auf die Lernwoche

Welche Aufgabe blieb offen und was war der Grund?
EOF
    git add REFLEXION.md
    git commit -q -m "Reflexionsfrage für den Wochenabschluss ergänzen"
    git push -q -u origin docs/wochenabschluss
)
git clone -q "$ziel/team.git" "$ziel/sam"
(
    cd "$ziel/sam"
    git remote set-url origin ../team.git
    git config user.name "Sam Beispiel"
    git config user.email "sam@taskflow.example"
    git config core.editor nano
    git config merge.conflictStyle merge
    git switch -q -c sam/weiterarbeit --track origin/docs/wochenabschluss
    cat > CHECKLISTE.md <<'EOF'
# Wochenabschluss prüfen

- Offene Aufgaben gesammelt?
- Hindernisse besprochen?
- Planung der nächsten Woche vorbereitet?
EOF
    git add CHECKLISTE.md
    git commit -q -m "Checkliste auf dem geteilten Wochenabschluss aufbauen"
    git push -q -u origin sam/weiterarbeit
    git switch -q main
    cat > WOCHENABSCHLUSS.md <<'EOF'
# Wochenabschluss im Lernteam

Offene Aufgaben werden am Sonntag mit Blick auf die nächste Woche besprochen.
EOF
    git add WOCHENABSCHLUSS.md
    git commit -q -m "Planung der nächsten Woche am Sonntag beschreiben"
    git push -q origin main
)
touch "$ziel/.taskflow-collaboration"
echo "Freier Übungsstand erstellt: $ziel/mein-taskflow"
echo "Ihr Wochenabschluss ist bereits geteilt. Sam hat darauf seine Checkliste aufgebaut."
echo "Das Teamrepository enthält außerdem eine unabhängige Änderung auf main."
