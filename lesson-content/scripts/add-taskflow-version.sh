#!/bin/bash

# Ergänzt die ausführbare Versionsoption, ohne Git-Verweise oder Commits zu ändern.
set -euo pipefail
if [ ! -d .git ] || [ ! -f ../.taskflow-final ]; then
    echo "Starten Sie die Implementierungshilfe im Projektordner Ihrer Challenge-Arbeitskopie."
    exit 1
fi
branch="$(git symbolic-ref --quiet --short HEAD)"
if [ "$branch" = "main" ]; then
    echo "Bereiten Sie den Beitrag zuerst auf einem eigenen Arbeitsbranch vor."
    exit 1
fi
if [ -n "$(git status --porcelain)" ] || [ -f .git/MERGE_HEAD ] || \
   [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
    echo "Prüfen Sie vor der Implementierung einen sauberen Arbeitsstand ohne laufende Integration."
    exit 1
fi
python3 - <<'PY'
from pathlib import Path
codepath = Path("taskflow.py")
versionpath = Path("version.txt")
code = codepath.read_text(encoding="utf-8")
if 'action="version"' in code:
    if versionpath.read_text(encoding="utf-8").strip() == "0.2.0":
        print("Die Versionsoption ist bereits angelegt. Es wurde nichts verändert.")
        raise SystemExit(0)
    raise SystemExit("Eine andere Versionsimplementierung ist vorhanden. Prüfen Sie den bisherigen Stand.")
anchor = "    parser.parse_args()\n"
if code.count(anchor) != 1 or versionpath.read_text(encoding="utf-8").strip() != "0.1.0":
    raise SystemExit("Der Programmstand entspricht nicht dem vorbereiteten Beispiel. Ihre Dateien bleiben erhalten.")
addition = '''    parser.add_argument(
        "--version",
        action="version",
        version="TaskFlow " + Path(__file__).with_name("version.txt").read_text(encoding="utf-8").strip(),
    )
'''
codepath.write_text(code.replace(anchor, addition + anchor), encoding="utf-8")
versionpath.write_text("0.2.0\n", encoding="utf-8")
print("taskflow.py unterstützt jetzt --version. version.txt enthält 0.2.0.")
print("Prüfen und versionieren Sie die Änderungen anschließend selbst.")
PY
