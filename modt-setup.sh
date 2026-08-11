#!/bin/bash
set -e

# Standard-MOTD deaktivieren
chmod -x /etc/update-motd.d/10-uname 2>/dev/null || true
rm -f /etc/motd

# Installationspfad abfragen
read -rp "Installationspfad des Dienstes: " SERVICE_PATH
echo "$SERVICE_PATH" > /etc/motd-service-path

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
echo "Installiert unter: $(cat /etc/motd-service-path)"
MOTDSCRIPT

chmod +x /etc/update-motd.d/05-custom
echo ""
echo "Fertig. Test mit: run-parts /etc/update-motd.d/"
