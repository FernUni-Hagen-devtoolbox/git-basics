#!/bin/bash

# Erstellt den vorbereiteten TaskFlow-Stand für die freie Übung in Notebook 02.
# Das Skript überschreibt kein bereits vorhandenes Übungsrepository.

set -euo pipefail

ziel="${1:-taskflow-undo-challenge}"

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

cat > CHANGELOG.md <<'EOF'
# Änderungen

- Projektübersicht angelegt.
EOF

git add README.md CHANGELOG.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "Projektgrundlage anlegen"

cat > FUNKTIONEN.md <<'EOF'
# Funktionen

Aufgaben lassen sich als PDF exportieren.
EOF

git add FUNKTIONEN.md
git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
    commit -q -m "PDF-Export dokumentieren"

cat > BEDIENUNG.md <<'EOF'
# Bedienung

Aufgaben können nach ihrem Status gefiltert werden.
EOF

git add BEDIENUNG.md
git -c user.name="Lea Beispiel" -c user.email="lea@beispiel.de" \
    commit -q -m "Update"

cat >> README.md <<'EOF'

Interne Testnotiz für die Entwicklung.
EOF

cat >> CHANGELOG.md <<'EOF'
- Filterhinweise ergänzt.
EOF

git add CHANGELOG.md

echo "Vorbereiteter Stand erstellt: $ziel"
echo "Wechseln Sie mit 'cd $ziel' in das Repository."
