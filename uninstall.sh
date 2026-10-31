#!/usr/bin/env bash
# Removes DUT. Leaves vnStat and its history in place (other tools may use it).
# Pass --purge to also delete your DUT settings.
set -uo pipefail

pkill -f "$HOME/.local/bin/dut" 2>/dev/null
rm -f "$HOME/.local/bin/dut" \
      "$HOME/.local/share/applications/dut.desktop" \
      "$HOME/.config/autostart/dut.desktop"
[ "${1:-}" = "--purge" ] && rm -rf "$HOME/.config/dut"

if [ -f /etc/systemd/system/dut-apps.service ]; then
  echo "Removing per-app tracking service (needs sudo)"
  sudo systemctl disable --now dut-apps.service
  sudo rm -f /etc/systemd/system/dut-apps.service
  sudo rm -rf /usr/local/lib/dut
  sudo systemctl daemon-reload
  [ "${1:-}" = "--purge" ] && sudo rm -rf /var/lib/dut
fi
echo "DUT removed."
