#!/bin/bash

# Erstellt unabhängige TaskFlow-Stände für Notebook 03 in MyBinder.
# Die Vergleichsrepositorys besitzen identische Dateien und Commit-Kennungen.
set -euo pipefail

ziel="${1:-taskflow-branches-uebung}"
if [ -e "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/branches" "$ziel/merge"

initialisieren() {
    git init -q -b main
    git config user.name "Lea Beispiel"
    git config user.email "lea@beispiel.de"
    git config core.editor nano
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow unterstützt Lerngruppen bei der Aufgabenplanung.
EOF
    cat > TEAM.md <<'EOF'
# Zusammenarbeit

Neue Dokumentation wird vor der Übernahme von Mira geprüft.
EOF
    git add README.md TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Projektübersicht und Teamregeln anlegen"
}

(
    cd "$ziel/branches"
    initialisieren
)
(
    cd "$ziel/merge"
    initialisieren
    git switch -q -c docs/filter
    cat > FILTER.md <<'EOF'
# Aufgaben filtern

Die Aufgabenliste kann auf ein bestimmtes Modul eingegrenzt werden.
EOF
    git add FILTER.md
    git commit -q -m "Modulfilter beschreiben"
    cat >> FILTER.md <<'EOF'

Erledigte Aufgaben können in der Ansicht ausgeblendet werden.
EOF
    git add FILTER.md
    git commit -q -m "Ausblenden erledigter Aufgaben beschreiben"
    git switch -q main
    cat >> TEAM.md <<'EOF'

Hinweise zu Filtern werden mit einer kleinen Beispielaufgabe geprüft.
EOF
    git add TEAM.md
    git -c user.name="Sam Beispiel" -c user.email="sam@taskflow.example" \
        commit -q -m "Prüfung der Filterhinweise festlegen"
    git switch -q -c sam/weiterarbeit docs/filter
    cat > BEISPIELE.md <<'EOF'
# Beispielaufgaben

Im Modul Programmierung soll das dritte Übungsblatt bearbeitet werden.
Ein ausgeblendeter erledigter Eintrag bleibt weiterhin gespeichert.
EOF
    git add BEISPIELE.md
    git -c user.name="Sam Beispiel" -c user.email="sam@taskflow.example" \
        commit -q -m "Beispielaufgaben für Filter ergänzen"
    git switch -q main
)
cp -R "$ziel/merge" "$ziel/rebase"
echo "Übungsstände erstellt: $ziel/branches, $ziel/merge und $ziel/rebase"
echo "Merge und Rebase starten mit identischen Commits. Sams Weiterarbeit liegt jeweils auf einem eigenen Branch."
