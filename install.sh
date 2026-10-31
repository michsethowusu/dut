#!/usr/bin/env bash
# Installs Data Usage for the current user and makes sure vnStat is running.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v vnstat >/dev/null; then
  echo "Installing vnStat (needs sudo)..."
  sudo apt-get install -y vnstat
fi
if ! python3 -c "import gi; gi.require_version('Gtk','3.0')" 2>/dev/null; then
  echo "Installing GTK Python bindings (needs sudo)..."
  sudo apt-get install -y python3-gi gir1.2-gtk-3.0
fi
if ! python3 -c "import gi; gi.require_version('AyatanaAppIndicator3','0.1')" 2>/dev/null &&
   ! python3 -c "import gi; gi.require_version('AppIndicator3','0.1')" 2>/dev/null; then
  echo "Installing top-bar icon support (needs sudo)..."
  sudo apt-get install -y gir1.2-ayatanaappindicator3-0.1 || sudo apt-get install -y gir1.2-appindicator3-0.1
fi
systemctl is-active --quiet vnstat || sudo systemctl enable --now vnstat

install -Dm755 data-usage "$HOME/.local/bin/data-usage"
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/data-usage.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Data Usage
Comment=Track internet data used against your plan (vnStat)
Exec=$HOME/.local/bin/data-usage
Icon=network-transmit-receive
Terminal=false
Categories=Network;Monitor;Utility;
Keywords=internet;data;bandwidth;usage;vnstat;
DESKTOP
# Start hidden in the top bar at login so warnings work even when the window is closed.
mkdir -p "$HOME/.config/autostart"
sed -e "s|^Exec=.*|Exec=$HOME/.local/bin/data-usage --hidden|" \
  "$HOME/.local/share/applications/data-usage.desktop" > "$HOME/.config/autostart/data-usage.desktop"

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
# Restart a running copy so the new version is used, then start it in the top bar.
pkill -f "$HOME/.local/bin/data-usage" 2>/dev/null || true
nohup "$HOME/.local/bin/data-usage" --hidden >/dev/null 2>&1 &
echo "Installed. Data Usage is in your top bar, and in your app menu."
