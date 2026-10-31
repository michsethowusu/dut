#!/usr/bin/env bash
# Removes LiDUT. Leaves vnStat and its history in place (other tools may use it).
# Pass --purge to also delete your LiDUT settings.
set -uo pipefail

pkill -f "$HOME/.local/bin/lidut" 2>/dev/null
rm -f "$HOME/.local/bin/lidut" \
      "$HOME/.local/share/applications/lidut.desktop" \
      "$HOME/.config/autostart/lidut.desktop"
[ "${1:-}" = "--purge" ] && rm -rf "$HOME/.config/lidut"

if [ -f /etc/systemd/system/lidut-apps.service ]; then
  echo "Removing per-app tracking service (needs sudo)"
  sudo systemctl disable --now lidut-apps.service
  sudo rm -f /etc/systemd/system/lidut-apps.service
  sudo rm -rf /usr/local/lib/lidut
  sudo systemctl daemon-reload
  [ "${1:-}" = "--purge" ] && sudo rm -rf /var/lib/lidut
fi
echo "LiDUT removed."
