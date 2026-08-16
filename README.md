# Server Scripts

Dieses Repository enthält nützliche Shell-Skripte zum Einrichten und Härten von Linux-Servern und Containern. Die Skripte sind für den Einsatz auf Debian-basierten Systemen bzw. in LXC-Containern gedacht und müssen in der Regel mit Root-Rechten ausgeführt werden.

Kurzbeschreibung

| Skript | Zweck | Kurzbeschreibung |
|---|---|---|
| `modt-setup.sh` | MOTD einrichten | Erzeugt `/etc/update-motd.d/05-custom`, speichert einen Service-Installationspfad in `/etc/motd-service-path` und zeigt beim Login eine ASCII-Überschrift sowie Systeminformationen (IP, Distribution, Virtualisierung, CPUs, RAM). Muss als Root ausgeführt werden. |
| `harden-lxc.sh` | LXC-Container härten | Härtet einen frisch erstellten LXC-Container: setzt SSH so, dass Root-Login nur per Public-Key möglich ist (kein Passwort über SSH), behält das Root-Passwort für die Proxmox-Konsole bei und entfernt ggf. Autologin-Overrides. Muss innerhalb des Containers als Root laufen; prüft, ob `/root/.ssh/authorized_keys` vorhanden ist. |
| `docker-setup.sh` | Docker installieren | Entfernt alte Docker-Pakete, fügt das offizielle Docker-APT-Repository hinzu, installiert Docker CE und zugehörige Komponenten und startet/aktiviert den Docker-Dienst. Geeignet für Debian-basierte Systeme; Ausführung als Root erforderlich. |

Verwendung

- Skripte ausführbar machen und als Root ausführen, z.B.:

```bash
sudo bash modt-setup.sh
sudo bash harden-lxc.sh    # innerhalb eines LXC-Containers
sudo bash docker-setup.sh  # auf einem Debian-basierten Host
```

Hinweise

- Die Skripte verändern Dateien in `/etc/` und sollten mit Vorsicht eingesetzt werden.
- Vor allem bei `harden-lxc.sh`: unbedingt in einer neuen SSH-Sitzung testen, ob der Key-Login funktioniert, bevor die aktuelle Sitzung geschlossen wird.
- Falls du möchtest, kann ich ein Uninstall-/Rollback-Skript oder zusätzliche Parameter und nicht-interaktive Optionen (z. B. für Automatisierung) hinzufügen.
