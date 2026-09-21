#!/bin/bash
# Erstellt initiale Dateien für Übung 01
# Idempotent: Kann mehrfach ausgeführt werden

# Prüfen ob wir in einem git repo sind
if [ ! -d ".git" ]; then
    echo "❌ Fehler: Bitte führen Sie dieses Script in einem Git-Repository aus."
    exit 1
fi

# Dateien erstellen (überschreiben existierende)
echo "# Mein Projekt" > readme.txt
echo "Dies ist eine README-Datei." >> readme.txt

echo "Testinhalt" > test.txt
echo "Zeile 2" >> test.txt

echo "✅ Dateien erstellt: readme.txt, test.txt"
