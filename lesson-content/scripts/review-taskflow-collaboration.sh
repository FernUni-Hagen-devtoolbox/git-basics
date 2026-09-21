#!/bin/bash

# Zeigt den tatsächlichen Beitrag und dokumentiert einen Review in Miras Rolle.
# Die Entscheidung wird von der übenden Person getroffen, nicht vom Skript.
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Verwendung: bash review-taskflow-collaboration.sh <uebungsordner> <quellbranch>"
    exit 1
fi
wurzel="$(cd "$1" && pwd -P)"
quellbranch="$2"
arbeitsrepo="$wurzel/mein-taskflow"
teamrepo="$wurzel/team.git"
if [ ! -f "$wurzel/.taskflow-collaboration" ] || \
   [ ! -d "$arbeitsrepo/.git" ] || [ ! -f "$teamrepo/HEAD" ]; then
    echo "Der Ordner ist kein vorbereiteter Stand für die Kollaborationsübung oder die Abschluss-Challenge."
    exit 1
fi
git check-ref-format "refs/heads/$quellbranch" >/dev/null
if [ -n "$(git -C "$arbeitsrepo" status --porcelain)" ] || \
   [ -d "$arbeitsrepo/.git/rebase-merge" ] || \
   [ -d "$arbeitsrepo/.git/rebase-apply" ] || \
   [ -f "$arbeitsrepo/.git/MERGE_HEAD" ]; then
    echo "Schließen Sie den laufenden Vorgang ab und prüfen Sie den sauberen Arbeitsstand vor dem Review."
    exit 1
fi
quelle="$(git -C "$teamrepo" rev-parse --verify "refs/heads/$quellbranch^{commit}")"
ziel="$(git -C "$teamrepo" rev-parse --verify 'refs/heads/main^{commit}')"
eigenerstand="$(git -C "$arbeitsrepo" rev-parse --verify "refs/heads/$quellbranch^{commit}")"
if [ "$quelle" != "$eigenerstand" ]; then
    echo "Der Quellbranch im Teamrepository entspricht noch nicht Ihrem fertigen Arbeitsbranch. Teilen Sie zuerst dessen aktuellen Stand."
    exit 1
fi
if ! git -C "$teamrepo" merge-base --is-ancestor "$ziel" "$quelle"; then
    echo "Der Beitrag enthält den aktuellen Teamhauptzweig noch nicht. Holen und integrieren Sie diesen Stand vor der Prüfung."
    exit 1
fi
if [ "$quelle" = "$ziel" ]; then
    echo "Quelle und Ziel enthalten bereits denselben Stand. Es gibt keinen neuen Beitrag zur Aufnahme."
    exit 1
fi
git -C "$teamrepo" diff --check "$ziel" "$quelle"
echo "=== Simulierte Prüfung in Miras Rolle ==="
echo "Quelle: $quellbranch im Teamrepository"
echo "Ziel: main im Teamrepository"
echo "Geprüfter Quellcommit: $quelle"
echo "Geprüfter Zielcommit: $ziel"
echo "Zusätzliche Commits:"
git -C "$teamrepo" --no-pager log --oneline "$ziel..$quelle"
echo "Dateivergleich des veröffentlichten Beitrags:"
git -C "$teamrepo" --no-pager diff "$ziel" "$quelle"
echo "Prüfen Sie jetzt als Mira die fachlichen Kriterien aus der Aufgabe."
echo "Das Skript prüft Git-Zustände und Leerraumfehler. Die fachliche Entscheidung treffen Sie."
read -r -p "Entscheidung (freigeben/überarbeiten): " entscheidung
case "$entscheidung" in
    freigeben) entscheidungstext="freigegeben" ;;
    überarbeiten|ueberarbeiten) entscheidungstext="Überarbeitung erforderlich" ;;
    *) echo "Keine gültige Entscheidung. Es wurde kein neuer Review dokumentiert."; exit 1 ;;
esac
read -r -p "Begründete Rückmeldung von Mira: " rueckmeldung
if [[ ! "$rueckmeldung" =~ [^[:space:]] ]]; then
    echo "Eine begründete Rückmeldung ist erforderlich. Es wurde kein neuer Review dokumentiert."
    exit 1
fi
# Die Freigabe darf keinen inzwischen geänderten Branch-Stand betreffen.
if [ "$quelle" != "$(git -C "$teamrepo" rev-parse "refs/heads/$quellbranch")" ] || \
   [ "$ziel" != "$(git -C "$teamrepo" rev-parse refs/heads/main)" ]; then
    echo "Quelle oder Ziel wurde während der Prüfung geändert. Prüfen Sie den neuen Stand erneut."
    exit 1
fi
bericht="$(mktemp "$wurzel/.review-XXXXXX")"
trap 'rm -f "$bericht"' EXIT
cat > "$bericht" <<EOF
Simulierter Review durch Mira
Quelle: $quellbranch im Teamrepository
Ziel: main im Teamrepository
Quellcommit: $quelle
Zielcommit: $ziel
Entscheidung: $entscheidungstext
Rückmeldung: $rueckmeldung

Die Entscheidung gilt für diese beiden Commit-Stände.
Der Review selbst hat keinen Branch verändert und keinen Beitrag integriert.
EOF
mv "$bericht" "$wurzel/review.txt"
echo "Miras simulierter Review ist dokumentiert: $wurzel/review.txt"
echo "Entscheidung: $entscheidungstext"
echo "Rückmeldung: $rueckmeldung"
