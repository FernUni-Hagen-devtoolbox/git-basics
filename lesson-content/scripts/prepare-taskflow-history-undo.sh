#!/bin/bash

# Erstellt den vorbereiteten TaskFlow-Stand für Notebook 02.
# Das Skript überschreibt kein bereits vorhandenes Übungsrepository.

set -euo pipefail

ziel="${1:-taskflow-history-undo}"

if [ -e "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Bitte prüfen Sie ihn oder verwenden Sie einen anderen Namen."
    exit 1
fi

mkdir "$ziel"
cd "$ziel"

git init -q -b main
git config user.name "Lea Beispiel"
git config user.email "lea@beispiel.de"
git config core.editor nano

cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lernteams bei der Aufgabenplanung.
EOF

git add README.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "Projektübersicht anlegen"

cat > BEDIENUNG.md <<'EOF'
# Bedienung

Aufgaben können angelegt und als erledigt markiert werden.
EOF

git add BEDIENUNG.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "Bedienhinweise ergänzen"

cat > TEAM.md <<'EOF'
# Zusammenarbeit

Neue Ideen werden vor der Umsetzung im Team besprochen.
EOF

git add TEAM.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "Teamregeln dokumentieren"

cat > CHANGELOG.md <<'EOF'
# Änderungen

- Projektübersicht und Bedienhinweise angelegt.
EOF

cat > notizen.txt <<'EOF'
Idee: Aufgaben nach Abgabedatum sortieren.
EOF

git add CHANGELOG.md notizen.txt
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "Änderungsübersicht und Ideenliste anlegen"

echo "Vorbereiteter Stand erstellt: $ziel"
echo "Wechseln Sie mit 'cd $ziel' in das Repository."
