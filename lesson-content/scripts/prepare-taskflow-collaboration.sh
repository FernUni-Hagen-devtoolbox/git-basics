#!/bin/bash

# Erstellt identische Ausgangsstände für den Konfliktvergleich in Notebook 05.
set -euo pipefail

ziel="${1:-taskflow-kollaboration-uebung}"
if [ -e "$ziel" ] || [ -L "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/merge/mein-taskflow"
git init -q --bare -b main "$ziel/merge/team.git"
(
    cd "$ziel/merge/mein-taskflow"
    git init -q -b main
    git config user.name "Lea Beispiel"
    git config user.email "lea@beispiel.de"
    git config core.editor nano
    git config merge.conflictStyle merge
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lernteams bei der gemeinsamen Aufgabenplanung.
EOF
    git add README.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "TaskFlow für Lernteams vorstellen"
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Beiträge entstehen auf eigenen Arbeitsbranches und werden vor der Aufnahme geprüft.
Mira koordiniert die Prüfung. Eine Freigabe bezieht sich auf den geprüften Stand.
EOF
    git add TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Prüfung von Teambeiträgen vereinbaren"
    cat > ZUSTAENDIGKEITEN.md <<'EOF'
# Zuständigkeiten im Lernteam

Für eine gemeinsame Aufgabe wird eine zuständige Person festgelegt.
EOF
    git add ZUSTAENDIGKEITEN.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Zuständigkeiten für gemeinsame Aufgaben einführen"
    git remote add origin ../team.git
    git push -q -u origin main
    git switch -q -c docs/zustaendigkeiten
    cat > ZUSTAENDIGKEITEN.md <<'EOF'
# Zuständigkeiten im Lernteam

Jede Person kann ihre Zuständigkeit für eine gemeinsame Aufgabe selbst festlegen.
EOF
    git add ZUSTAENDIGKEITEN.md
    git commit -q -m "Eigene Übernahme einer Aufgabe beschreiben"
    cat > BEISPIELE.md <<'EOF'
# Beispiel aus dem Lernteam

Lea schlägt vor, das Übungsblatt zur Programmierung zu übernehmen.
EOF
    git add BEISPIELE.md
    git commit -q -m "Beispiel zur Aufgabenübernahme ergänzen"
)
git clone -q "$ziel/merge/team.git" "$ziel/merge/sam"
(
    cd "$ziel/merge/sam"
    git remote set-url origin ../team.git
    git config user.name "Sam Beispiel"
    git config user.email "sam@taskflow.example"
    git config core.editor nano
    git config merge.conflictStyle merge
    cat > ZUSTAENDIGKEITEN.md <<'EOF'
# Zuständigkeiten im Lernteam

Das Lernteam legt die Zuständigkeit für eine gemeinsame Aufgabe gemeinsam fest.
EOF
    git add ZUSTAENDIGKEITEN.md
    git commit -q -m "Gemeinsame Entscheidung über Zuständigkeiten beschreiben"
    git push -q origin main
)
touch "$ziel/merge/.taskflow-collaboration"
cp -R "$ziel/merge" "$ziel/rebase"
echo "Übungsstände erstellt: $ziel/merge und $ziel/rebase"
echo "Beide Arbeitskopien starten mit identischen Commits auf docs/zustaendigkeiten."
echo "Ihre zwei Arbeitscommits wurden noch nicht geteilt. Sam hat main unabhängig erweitert."
