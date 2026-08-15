# server-modt

Dieses Repository enthält ein kleines Shell-Skript zum Einrichten einer benutzerdefinierten Message of the Day (MOTD) auf einem Linux-Server.

## Enthaltene Scripts

- `modt-setup.sh`

  Beschreibung:
  - Deaktiviert das vorhandene `/etc/update-motd.d/10-uname` (setzt das Ausführungsbit aus) und entfernt `/etc/motd`, sofern vorhanden.
  - Fragt interaktiv nach dem Installationspfad des Dienstes (`Installationspfad des Dienstes:`) und speichert diesen Pfad in `/etc/motd-service-path`.
  - Erzeugt das Skript `/etc/update-motd.d/05-custom`, das beim Login eine hübsche ASCII-Überschrift sowie folgende Systeminformationen anzeigt:
    - IP-Adresse
    - Distribution (PRETTY_NAME aus `/etc/os-release`)
    - Ob das System virtualisiert ist
    - Anzahl CPUs
    - RAM-Größe
    - Den zuvor gespeicherten Installationspfad
  - Macht `/etc/update-motd.d/05-custom` ausführbar.
  - Am Ende wird ein Hinweis ausgegeben, wie man die MOTD sofort testet: `run-parts /etc/update-motd.d/`.

  Hinweise zur Verwendung:
  - Das Script verändert Dateien in `/etc/` und muss daher als Root (z. B. via `sudo`) ausgeführt werden.
  - Es ist idempotent in dem Sinne, dass es bestehende Einträge überschreibt bzw. vorhandene Dateien entfernt/überschreibt.
  - Testen: `run-parts /etc/update-motd.d/` zeigt die neue MOTD an.

Wenn du möchtest, kann ich zusätzliche Erklärungen, Optionen oder ein Uninstall-Skript hinzufügen.