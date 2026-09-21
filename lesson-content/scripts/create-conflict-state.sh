#!/bin/bash
# Erstellt spezifischen Zustand für selektives Staging
# - readme.txt: geändert, NICHT gestaged
# - test.txt: geändert, NICHT gestaged
# - notes.txt: neu, NICHT gestaged
# Idempotent: Kann mehrfach ausgeführt werden

# Prüfen ob wir in einem git repo sind
if [ ! -d ".git" ]; then
    echo "❌ Fehler: Bitte führen Sie dieses Script in einem Git-Repository aus."
    exit 1
fi

# readme.txt ändern
if [ -f "readme.txt" ]; then
    echo "Diese Zeile wurde hinzugefügt." >> readme.txt
    echo "✅ readme.txt geändert."
else
    echo "# Neues Projekt" > readme.txt
    echo "✅ readme.txt erstellt."
fi

# test.txt ändern
if [ -f "test.txt" ]; then
    echo "Weitere Änderung." >> test.txt
    echo "✅ test.txt geändert."
else
    echo "Testinhalt" > test.txt
    echo "✅ test.txt erstellt."
fi

# notes.txt erstellen (neu)
echo "Notiz 1" > notes.txt
echo "✅ notes.txt erstellt."

echo ""
echo "📋 Zustand:"
echo "  - readme.txt: geändert (nicht gestaged)"
echo "  - test.txt: geändert (nicht gestaged)"
echo "  - notes.txt: neu (nicht gestaged)"
echo ""
echo "💡 Aufgabe: Fügen Sie NUR readme.txt zur Staging Area hinzu."
