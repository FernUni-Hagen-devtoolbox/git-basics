#!/bin/bash

# Erstellt zwei unabhängige Fälle für die freie Aufgabe in Notebook 03.
set -euo pipefail

ziel="${1:-taskflow-branches-challenge}"
if [ -e "$ziel" ]; then
    echo "Der Ordner '$ziel' existiert bereits. Prüfen Sie den bisherigen Stand oder wählen Sie einen anderen Namen."
    exit 1
fi
mkdir -p "$ziel/privat" "$ziel/geteilt"

initialisieren() {
    git init -q -b main
    git config user.name "Lea Beispiel"
    git config user.email "lea@beispiel.de"
    git config core.editor nano
    cat > README.md <<'EOF'
# TaskFlow

TaskFlow verwaltet Aufgaben für das Studium.
EOF
    cat > TEAM.md <<'EOF'
# Teamregeln

Mira prüft Beiträge vor der Freigabe.
EOF
    git add README.md TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "TaskFlow-Grundstand bereitstellen"
}

(
    cd "$ziel/privat"
    initialisieren
    git switch -q -c docs/export
    cat > EXPORT.md <<'EOF'
# Aufgaben exportieren

Aufgaben können als Textliste ausgegeben werden.
EOF
    git add EXPORT.md
    git commit -q -m "Textexport beschreiben"
    cat >> EXPORT.md <<'EOF'

Der Export verändert die gespeicherten Aufgaben nicht.
EOF
    git add EXPORT.md
    git commit -q -m "Unveränderte Aufgaben beim Export erklären"
    git switch -q main
    cat >> README.md <<'EOF'

Die Dokumentation richtet sich auch an neue Teammitglieder.
EOF
    git add README.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Zielgruppe der Dokumentation ergänzen"
)
(
    cd "$ziel/geteilt"
    initialisieren
    git switch -q -c docs/abgaben
    cat > ABGABEN.md <<'EOF'
# Abgaben planen

Aufgaben können ein Abgabedatum erhalten.
EOF
    git add ABGABEN.md
    git commit -q -m "Abgabedatum beschreiben"
    cat >> ABGABEN.md <<'EOF'

Die Aufgabenliste kann nach Abgabedatum sortiert werden.
EOF
    git add ABGABEN.md
    git commit -q -m "Sortierung nach Abgabedatum erklären"
    git switch -q main
    cat >> TEAM.md <<'EOF'

Abgabetermine werden vor der Übernahme auf Verständlichkeit geprüft.
EOF
    git add TEAM.md
    git -c user.name="Mira Muster" -c user.email="mira@taskflow.example" \
        commit -q -m "Prüfung der Abgabehinweise festlegen"
    git switch -q -c sam/weiterarbeit docs/abgaben
    cat > CHECKLISTE.md <<'EOF'
# Abgaben prüfen

- Abgabedatum eingetragen?
- Reihenfolge der Aufgaben geprüft?
EOF
    git add CHECKLISTE.md
    git -c user.name="Sam Beispiel" -c user.email="sam@taskflow.example" \
        commit -q -m "Checkliste für Abgaben ergänzen"
    git switch -q main
)
echo "Freie Übungsstände erstellt: $ziel/privat und $ziel/geteilt"
