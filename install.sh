#!/usr/bin/env bash
# Installs Bytecap for the current user and makes sure vnStat is running.
# Usage: ./install.sh        (asks for sudo only if system packages are missing)
set -euo pipefail
cd "$(dirname "$0")"

# 1. System packages (see requirements.txt)
missing=()
command -v vnstat >/dev/null || missing+=(vnstat)
python3 -c "import gi; gi.require_version('Gtk','3.0')" 2>/dev/null || missing+=(python3-gi gir1.2-gtk-3.0)
python3 -c "import gi; gi.require_version('AyatanaAppIndicator3','0.1')" 2>/dev/null ||
  python3 -c "import gi; gi.require_version('AppIndicator3','0.1')" 2>/dev/null ||
  missing+=(gir1.2-ayatanaappindicator3-0.1)
command -v notify-send >/dev/null || missing+=(libnotify-bin)
if [ ${#missing[@]} -gt 0 ]; then
  echo "Installing: ${missing[*]} (needs sudo)"
  sudo apt-get install -y "${missing[@]}"
fi
systemctl is-active --quiet vnstat || sudo systemctl enable --now vnstat

# 2. Move over settings from the old "data-usage" name, and remove the old copy
if [ -d "$HOME/.config/data-usage" ] && [ ! -d "$HOME/.config/bytecap" ]; then
  mv "$HOME/.config/data-usage" "$HOME/.config/bytecap"
fi
pkill -f "$HOME/.local/bin/data-usage" 2>/dev/null || true
rm -f "$HOME/.local/bin/data-usage" \
      "$HOME/.local/share/applications/data-usage.desktop" \
      "$HOME/.config/autostart/data-usage.desktop"

# 3. The app, its menu entry, and autostart (hidden in the top bar at login)
install -Dm755 bytecap "$HOME/.local/bin/bytecap"
mkdir -p "$HOME/.local/share/applications" "$HOME/.config/autostart"
cat > "$HOME/.local/share/applications/bytecap.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Bytecap
GenericName=Data Usage Monitor
Comment=Track internet data used against a daily cap or monthly plan
Exec=$HOME/.local/bin/bytecap
Icon=network-transmit-receive
Terminal=false
Categories=Network;Monitor;Utility;
Keywords=internet;data;bandwidth;usage;cap;vnstat;
DESKTOP
sed -e "s|^Exec=.*|Exec=$HOME/.local/bin/bytecap --hidden|" \
  "$HOME/.local/share/applications/bytecap.desktop" > "$HOME/.config/autostart/bytecap.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# 4. (Re)start it in the top bar
pkill -f "$HOME/.local/bin/bytecap" 2>/dev/null || true
nohup "$HOME/.local/bin/bytecap" --hidden >/dev/null 2>&1 &
echo "Installed. Bytecap is in your top bar and your app menu."
echo "Optional per-app tracking: sudo ./install-app-tracking.sh"
