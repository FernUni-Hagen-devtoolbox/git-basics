#!/bin/bash

# Veröffentlicht die im Notebook vorgesehenen Beiträge von Sam.
# Ein bereits abgeschlossener Schritt wird nicht erneut ausgeführt.
set -euo pipefail

schritt="${1:-}"
ziel="${2:-taskflow-remotes-uebung}"
case "$schritt" in
    listen|fortschritt|sortierung) ;;
    *)
        echo "Aufruf: bash simulate-taskflow-remotes.sh <listen|fortschritt|sortierung> <uebungsordner>"
        exit 1
        ;;
esac
if [ ! -f "$ziel/.taskflow-remotes" ] || [ ! -d "$ziel/sam/.git" ] || [ ! -f "$ziel/team.git/HEAD" ]; then
    echo "Der vorbereitete Übungsordner wurde nicht gefunden. Prüfen Sie den übergebenen Pfad."
    exit 1
fi
ziel=$(cd "$ziel" && pwd -P)
markierung="$ziel/.simulation-$schritt"
if [ -f "$markierung" ]; then
    echo "Sams Schritt '$schritt' wurde bereits veröffentlicht. Es wird nichts erneut geändert."
    exit 0
fi
if [ "$schritt" = fortschritt ] && [ ! -f "$ziel/.simulation-listen" ]; then
    echo "Führen Sie zuerst den Listen-Schritt aus dem Notebook aus."
    exit 1
fi
if [ "$schritt" = sortierung ] && [ ! -f "$ziel/.simulation-fortschritt" ]; then
    echo "Bearbeiten Sie zuerst den Merge-Schritt aus dem Notebook."
    exit 1
fi
cd "$ziel/sam"
if [ -n "$(git status --porcelain)" ]; then
    echo "Sams Arbeitsrepository enthält offene Änderungen. Prüfen Sie sie vor dem simulierten Beitrag."
    exit 1
fi
if [ "$(git branch --show-current)" != main ] || [ "$(git remote get-url origin)" != ../team.git ]; then
    echo "Sams vorbereiteter Branch oder seine Verbindung wurde geändert. Prüfen Sie den Stand."
    exit 1
fi
git fetch -q origin
case "$schritt" in
    fortschritt)
        if ! git cat-file -e origin/main:START.md 2>/dev/null; then
            echo "Veröffentlichen Sie zuerst Ihren START.md-Beitrag aus dem Notebook."
            exit 1
        fi
        datei=FORTSCHRITT.md
        nachricht="Wöchentliche Besprechung des Lernfortschritts ergänzen"
        zeile="Das Team bespricht einmal pro Woche den aktuellen Lernfortschritt."
        ;;
    sortierung)
        if ! git cat-file -e origin/main:LERNPLAN.md 2>/dev/null; then
            echo "Teilen Sie zuerst den zusammengeführten LERNPLAN.md-Beitrag aus der Merge-Aufgabe."
            exit 1
        fi
        datei=LISTEN.md
        nachricht="Sortierung der Aufgabenlisten beschreiben"
        zeile="Eine Liste kann nach Abgabedatum sortiert angezeigt werden."
        ;;
    listen)
        datei=LISTEN.md
        nachricht="Aufgabenlisten für einzelne Module beschreiben"
        zeile="Für jedes Modul kann eine eigene Aufgabenliste angelegt werden."
        ;;
esac
git merge -q --ff-only origin/main
# Nach einer Unterbrechung zwischen Commit und Push wird der vorhandene Beitrag verwendet.
if ! git log --format=%s | grep -F -x "$nachricht" >/dev/null; then
    printf '\n%s\n' "$zeile" >> "$datei"
    git add "$datei"
    git commit -q -m "$nachricht"
fi
git push -q origin main
touch "$markierung"
echo "Sam hat den Beitrag '$nachricht' ins Teamrepository übertragen."
echo "Ihr Arbeitsrepository wurde dadurch nicht geändert."
