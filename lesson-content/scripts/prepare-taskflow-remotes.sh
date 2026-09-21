#!/bin/bash

# Erstellt die Austauschstelle und Sams Arbeitsrepository für Notebook 04.
set -euo pipefail

ziel="${1:-taskflow-remotes-uebung}"
if [ -e "$ziel" ] || [ -L "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/sam"
git init -q --bare -b main "$ziel/team.git"
(
    cd "$ziel/sam"
    git init -q -b main
    git config user.name "Sam Beispiel"
    git config user.email "sam@taskflow.example"
    git config core.editor nano
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lernteams bei der Planung ihrer Aufgaben.
EOF
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Neue Dokumentation wird vor der Übernahme von Mira geprüft.
EOF
    git add README.md TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Projektübersicht und Teamregeln anlegen"
    cat > LISTEN.md <<'EOF'
# Aufgabenlisten

Aufgaben können in einer gemeinsamen Liste gesammelt werden.
EOF
    git add LISTEN.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Gemeinsame Aufgabenliste beschreiben"
    cat > FORTSCHRITT.md <<'EOF'
# Lernfortschritt

Erledigte Aufgaben bleiben zur Übersicht in der Liste sichtbar.
EOF
    git add FORTSCHRITT.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Sichtbaren Lernfortschritt erklären"
    git remote add origin ../team.git
    git push -q -u origin main
)
touch "$ziel/.taskflow-remotes"
echo "Vorbereiteter Teamstand erstellt: $ziel/team.git"
echo "Sams Arbeitsrepository: $ziel/sam"
echo "Erstellen Sie Ihre Arbeitskopie anschließend mit dem Klonauftrag im Notebook."
