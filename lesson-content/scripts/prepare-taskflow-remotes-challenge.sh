#!/bin/bash

# Erstellt einen noch nicht geteilten Wochenplan und eine unabhängige Teamerweiterung.
set -euo pipefail

ziel="${1:-taskflow-remotes-challenge}"
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
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lernteams bei der Aufgabenplanung.
EOF
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Neue Dokumentation wird vor der Übernahme von Mira geprüft.
EOF
    git add README.md TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "TaskFlow-Teamstand bereitstellen"
    cat > LISTEN.md <<'EOF'
# Aufgabenlisten

Aufgaben können nach Modul gruppiert werden.
EOF
    git add LISTEN.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Gruppierung nach Modul beschreiben"
    cat > FORTSCHRITT.md <<'EOF'
# Lernfortschritt

Das Lernteam bespricht wöchentlich den Arbeitsstand.
EOF
    git add FORTSCHRITT.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Wöchentlichen Austausch dokumentieren"
    git push -q ../team.git main
    git switch -q -c docs/wochenplanung
    cat > WOCHENPLAN.md <<'EOF'
# Wochenplanung

Zu Wochenbeginn werden die Aufgaben für die nächsten Tage ausgewählt.
EOF
    git add WOCHENPLAN.md
    git commit -q -m "Auswahl der Wochenaufgaben beschreiben"
    cat >> WOCHENPLAN.md <<'EOF'

Das Team verteilt die ausgewählten Aufgaben nach verfügbarer Zeit.
EOF
    git add WOCHENPLAN.md
    git commit -q -m "Verteilung der Wochenaufgaben erklären"
)
git clone -q "$ziel/team.git" "$ziel/sam"
(
    cd "$ziel/sam"
    git config user.name "Sam Beispiel"
    git config user.email "sam@taskflow.example"
    git config core.editor nano
    cat > CHECKLISTE.md <<'EOF'
# Wochenplanung prüfen

- Abgabetermine berücksichtigt?
- Verfügbare Lernzeit besprochen?
- Zuständigkeiten geklärt?
EOF
    git add CHECKLISTE.md
    git commit -q -m "Checkliste zur Wochenplanung ergänzen"
    git push -q origin main
)
echo "Freier Übungsstand erstellt: $ziel/mein-taskflow"
echo "Teamrepository: $ziel/team.git"
echo "Ihre Arbeitskopie hat noch keine Remote-Verbindung. Der Wochenplan wurde noch nicht geteilt."
