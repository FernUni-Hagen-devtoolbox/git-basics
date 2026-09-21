#!/bin/bash
# Ändert readme.txt (neue Zeile hinzufügen)
# Idempotent: Kann mehrfach ausgeführt werden

# Prüfen ob readme.txt existiert
if [ ! -f "readme.txt" ]; then
    echo "❌ Fehler: readme.txt nicht gefunden. Bitte führen Sie zuerst create-initial-files.sh aus."
    exit 1
fi

# Neue Zeile hinzufügen
echo "Neue Zeile hinzugefügt." >> readme.txt

echo "✅ readme.txt geändert."
