#!/bin/bash
set -e

# Standard-MOTD deaktivieren
chmod -x /etc/update-motd.d/10-uname 2>/dev/null || true
rm -f /etc/motd

# Dienste interaktiv abfragen
echo "Dienste für dieses System eintragen (leerer Name zum Beenden):"
SERVICES_CONF="/etc/motd-services.conf"
> "$SERVICES_CONF"

while true; do
  read -rp "Dienstname: " name
  [ -z "$name" ] && break
  read -rp "Pfad: " path
  echo "${name}=${path}" >> "$SERVICES_CONF"
done

# Eigenes MOTD-Skript schreiben
cat > /etc/update-motd.d/05-custom << 'MOTDSCRIPT'
#!/bin/bash
cat << "EOF"
      ___           ___           ___           ___                 
     /  /\         /  /\         /  /\         /__/|          ___   
    /  /::\       /  /::\       /  /:/        |  |:|         /__/|  
   /  /:/\:\     /  /:/\:\     /  /:/         |  |:|        |  |:|  
  /  /:/~/:/    /  /:/  \:\   /  /:/  ___   __|  |:|        |  |:|  
 /__/:/ /:/___ /__/:/ \__\:\ /__/:/  /  /\ /__/\_|:|____  __|__|:|  
 \  \:\/:::::/ \  \:\ /  /:/ \  \:\ /  /:/ \  \:\/:::::/ /__/::::\  
  \  \::/~~~~   \  \:\  /:/   \  \:\  /:/   \  \::/~~~~     ~\~~\:\ 
   \  \:\        \  \:\/:/     \  \:\/:/     \  \:\           \  \:\
    \  \:\        \  \::/       \  \::/       \  \:\           \__\/
     \__\/         \__\/         \__\/         \__\/                
EOF

echo ""
echo "FQDN:    $(hostname -f)"
echo "Distro:  $(source /etc/os-release; echo $PRETTY_NAME)"
echo "Virtual: $(systemd-detect-virt -q && echo YES || echo NO)"
echo "CPUs:    $(nproc)"
echo "RAM:     $(free -h --si | awk '/^Mem:/{print $2}')"
echo ""
echo "Dienste auf diesem Host:"
while IFS='=' read -r name path; do
  [ -z "$name" ] && continue
  printf "  %-15s %s\n" "$name" "$path"
done < /etc/motd-services.conf
MOTDSCRIPT

chmod +x /etc/update-motd.d/05-custom
echo ""
echo "Fertig. Test mit: run-parts /etc/update-motd.d/"