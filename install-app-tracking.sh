#!/usr/bin/env bash
# Optional: per-app data tracking for DUT. Installs NetHogs and a small
# background service (runs as root, because seeing which program owns network
# traffic needs admin rights). Run with: sudo ./install-app-tracking.sh
set -euo pipefail
cd "$(dirname "$0")"

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run with sudo: sudo ./install-app-tracking.sh"
  exit 1
fi

command -v nethogs >/dev/null || apt-get install -y nethogs

install -Dm755 dut-collector /usr/local/lib/dut/dut-collector
cat > /etc/systemd/system/dut-apps.service <<'EOF'
[Unit]
Description=DUT per-app traffic collector (NetHogs)
After=network.target

[Service]
ExecStart=/usr/bin/python3 -I /usr/local/lib/dut/dut-collector
Restart=always
RestartSec=10
Nice=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now dut-apps.service
systemctl restart dut-apps.service
echo "Per-app tracking is running. Open DUT and look at the Apps tab."
echo "To remove: sudo systemctl disable --now dut-apps && sudo rm /etc/systemd/system/dut-apps.service"
