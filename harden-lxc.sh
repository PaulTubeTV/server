#!/usr/bin/env bash
#
# harden-lxc.sh
#
# Härtet einen frisch erstellten LXC-Container (Proxmox):
#   - erzwingt SSH-Login für root nur per Key (kein Passwort mehr über SSH)
#   - root-Passwort bleibt aktiv für Login über die Proxmox-Konsole (noVNC)
#   - entfernt Autologin auf der Konsole (tty1 / container-getty), falls vorhanden
#
# Muss als root INNERHALB des Containers ausgeführt werden.
#
# Voraussetzung: Der SSH-Key wurde bereits über das Proxmox-Interface
# beim Erstellen des Containers hinzugefügt (landet in /root/.ssh/authorized_keys).
#
# WICHTIG: Nach dem Lauf in einer NEUEN Sitzung testen, ob der Login
# per Key noch funktioniert, BEVOR du die aktuelle Sitzung schließt!

set -euo pipefail

AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
SSHD_CONFIG="/etc/ssh/sshd_config"

echo "==> Prüfe, ob ein SSH-Key für root hinterlegt ist..."
if [[ ! -s "$AUTHORIZED_KEYS" ]]; then
    echo "FEHLER: $AUTHORIZED_KEYS existiert nicht oder ist leer."
    echo "Zuerst im Proxmox-Interface den SSH-Key für den Container hinzufügen,"
    echo "sonst sperrst du dich komplett aus."
    exit 1
fi
echo "    OK - $(grep -c '^ssh-' "$AUTHORIZED_KEYS" 2>/dev/null || echo '1') Key(s) gefunden."

echo "==> Setze Rechte für .ssh / authorized_keys..."
chmod 700 /root/.ssh
chmod 600 "$AUTHORIZED_KEYS"
chown -R root:root /root/.ssh

echo "==> Passe $SSHD_CONFIG an..."
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

set_sshd_option() {
    local key="$1"
    local value="$2"
    if grep -qE "^[#[:space:]]*${key}[[:space:]]" "$SSHD_CONFIG"; then
        sed -i -E "s|^[#[:space:]]*${key}[[:space:]].*|${key} ${value}|" "$SSHD_CONFIG"
    else
        echo "${key} ${value}" >> "$SSHD_CONFIG"
    fi
}

set_sshd_option "PermitRootLogin" "prohibit-password"
set_sshd_option "PasswordAuthentication" "no"
set_sshd_option "KbdInteractiveAuthentication" "no"
set_sshd_option "PubkeyAuthentication" "yes"

echo "==> Prüfe sshd-Konfiguration auf Syntaxfehler..."
sshd -t

echo "==> Starte sshd neu..."
if systemctl list-unit-files | grep -q '^ssh\.service'; then
    systemctl restart ssh
elif systemctl list-unit-files | grep -q '^sshd\.service'; then
    systemctl restart sshd
else
    echo "WARNUNG: Konnte den SSH-Service-Namen nicht automatisch bestimmen."
    echo "Bitte manuell neu starten (z.B. 'systemctl restart ssh' oder 'sshd')."
fi

echo ""
echo "==> !!! WICHTIG !!!"
echo "Öffne JETZT eine NEUE Terminal-Sitzung und teste den Login per Key,"
echo "bevor du dich auf SSH verlässt:"
echo "    ssh root@<container-ip>"
echo "(Das root-Passwort bleibt aktiv - falls SSH per Key nicht klappt,"
echo "kommst du weiterhin über die Proxmox-Konsole mit Passwort rein.)"
echo ""

echo "==> Prüfe auf Autologin über getty..."
AUTOLOGIN_FOUND=0
for unit in "container-getty@1.service" "container-getty@0.service" "getty@tty1.service"; do
    OVERRIDE_DIR="/etc/systemd/system/${unit}.d"
    if [[ -d "$OVERRIDE_DIR" ]]; then
        if grep -rl "autologin" "$OVERRIDE_DIR" >/dev/null 2>&1; then
            AUTOLOGIN_FOUND=1
            echo "    Autologin-Override gefunden in $OVERRIDE_DIR - wird entfernt."
            rm -rf "$OVERRIDE_DIR"
        fi
    fi
done

if [[ "$AUTOLOGIN_FOUND" -eq 1 ]]; then
    systemctl daemon-reload
    echo "    Autologin entfernt, systemd neu geladen."
else
    echo "    Kein Autologin-Override gefunden."
fi

echo ""
echo "==> Fertig. Zusammenfassung:"
echo "    - Root-Login per SSH nur noch mit Key möglich (kein Passwort über SSH)"
echo "    - root-Passwort bleibt aktiv für Login über die Proxmox-Konsole (noVNC)"
echo "    - Autologin auf der Konsole entfernt (falls vorhanden)"
echo "    - Backup der alten sshd_config: ${SSHD_CONFIG}.bak.*"
