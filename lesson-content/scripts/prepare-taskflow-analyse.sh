#!/bin/bash

# Erstellt einen vorbereiteten TaskFlow-Stand für die freie Übung in Notebook 01.
# Das Skript überschreibt kein bereits vorhandenes Übungsrepository.

set -euo pipefail

ziel="${1:-taskflow-analyse}"

if [ -e "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Bitte prüfen Sie ihn oder verwenden Sie einen anderen Namen."
    exit 1
fi

mkdir "$ziel"
cd "$ziel"

git init -b main

cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lernteams bei der Aufgabenplanung.
EOF

git add README.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -m "Projektbeschreibung anlegen"

cat > TEAM.md <<'EOF'
# Zusammenarbeit

Neue Ideen werden zuerst im Team besprochen.
EOF

git add TEAM.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -m "Regel für Zusammenarbeit ergänzen"

cat >> README.md <<'EOF'

Weitere Hinweise für das Team folgen.
EOF

cat > CHANGELOG.md <<'EOF'
# Geplante Dokumentation

- Eine kurze Einführung für neue Teammitglieder.
EOF

echo "Vorbereiteter Stand erstellt: $ziel"
echo "Wechseln Sie mit 'cd $ziel' in das Repository."
