#!/usr/bin/env bash
# Removes Bytecap. Leaves vnStat and its history in place (other tools may use it).
# Pass --purge to also delete your Bytecap settings.
set -uo pipefail

pkill -f "$HOME/.local/bin/bytecap" 2>/dev/null
rm -f "$HOME/.local/bin/bytecap" \
      "$HOME/.local/share/applications/bytecap.desktop" \
      "$HOME/.config/autostart/bytecap.desktop"
[ "${1:-}" = "--purge" ] && rm -rf "$HOME/.config/bytecap"

if [ -f /etc/systemd/system/bytecap-apps.service ]; then
  echo "Removing per-app tracking service (needs sudo)"
  sudo systemctl disable --now bytecap-apps.service
  sudo rm -f /etc/systemd/system/bytecap-apps.service
  sudo rm -rf /usr/local/lib/bytecap
  sudo systemctl daemon-reload
  [ "${1:-}" = "--purge" ] && sudo rm -rf /var/lib/bytecap
fi
echo "Bytecap removed."
