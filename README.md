# Git Basics

Dieses Repository enthält die praktischen Übungen eines Git-Kurses für Programmieranfängerinnen und Programmieranfänger. Die Übungen werden in MyBinder bearbeitet. Jede Übung öffnet ein Jupyter Notebook auf der linken Seite und ein vorbereitetes Terminal auf der rechten Seite.

## Übungen in MyBinder

| Kursteil | MyBinder starten |
| --- | --- |
| Abschnitt 1: Git-Grundlagen | [Übung 1 öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/uebung-01) |
| Abschnitt 2: Historie und Änderungen rückgängig machen | [Übung 2 öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/uebung-02) |
| Abschnitt 3: Branches, Merge und Rebase | [Übung 3 öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/uebung-03) |
| Abschnitt 4: Remote-Repositories | [Übung 4 öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/uebung-04) |
| Abschnitt 5: Zusammenarbeit und Merge-Konflikte | [Übung 5 öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/uebung-05) |
| Abschluss-Challenge | [Challenge öffnen](https://mybinder.org/v2/gh/FernUni-Hagen-devtoolbox/git-basics/main?urlpath=lab/workspaces/abschluss-challenge) |

Beim ersten Aufruf eines neuen Repository-Stands muss MyBinder die Umgebung zunächst erstellen. Dieser Vorgang kann einige Minuten dauern.

Eine MyBinder-Sitzung ist zeitlich begrenzt. Änderungen, Repositories und Commits innerhalb der Sitzung stehen nach dem Beenden der Umgebung nicht mehr zur Verfügung.

## Aufbau des Repositorys

- `lesson-content/` enthält die sechs Jupyter Notebooks und die benötigten Vorbereitungsskripte.
- `.binder/Dockerfile` beschreibt die MyBinder-Umgebung mit Git, Nano, Hilfeseiten und Bash-Kernel.
- `.binder/workspaces/` enthält die vorbereiteten JupyterLab-Ansichten für die einzelnen Übungen.
- `Makefile` stellt Befehle zum lokalen Bauen und Testen der Umgebung bereit.

## Lokaler Test

Für einen lokalen Test werden Docker und Make benötigt.

Das Binder-kompatible Image wird mit folgendem Befehl erstellt:

```bash
make build
```

Anschließend kann die erste Übung gestartet werden:

```bash
make run
```

Ein anderer Workspace wird über seinen Namen ausgewählt:

```bash
make run WORKSPACE=uebung-03
```

JupyterLab ist danach unter `http://127.0.0.1:8888` erreichbar. Der laufende Container wird mit folgendem Befehl beendet:

```bash
make stop
```

## Enthaltene Werkzeuge

Die MyBinder-Umgebung enthält:

- Git
- Nano
- Git- und Shell-Hilfeseiten
- einen Bash-Kernel für die Jupyter Notebooks

Git verwendet innerhalb der Übungsumgebung den Hauptzweig `main`. Nano ist als Standardeditor für Git konfiguriert.
