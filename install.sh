#!/usr/bin/env bash
# Installs Lidut for the current user and makes sure vnStat is running.
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

# 2. Move over settings from earlier names (data-usage, bytecap) and remove old copies
for old in data-usage bytecap; do
  if [ -d "$HOME/.config/$old" ] && [ ! -d "$HOME/.config/lidut" ]; then
    mv "$HOME/.config/$old" "$HOME/.config/lidut"
  fi
  pkill -f "$HOME/.local/bin/$old" 2>/dev/null || true
  rm -f "$HOME/.local/bin/$old" \
        "$HOME/.local/share/applications/$old.desktop" \
        "$HOME/.config/autostart/$old.desktop"
done

# 3. The app, its menu entry, and autostart (hidden in the top bar at login)
install -Dm755 lidut "$HOME/.local/bin/lidut"
mkdir -p "$HOME/.local/share/applications" "$HOME/.config/autostart"
cat > "$HOME/.local/share/applications/lidut.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Lidut
GenericName=Linux Data Usage Tracker
Comment=Track internet data used against a daily cap or monthly plan
Exec=$HOME/.local/bin/lidut
Icon=network-transmit-receive
Terminal=false
Categories=Network;Monitor;Utility;
Keywords=internet;data;bandwidth;usage;cap;vnstat;
DESKTOP
sed -e "s|^Exec=.*|Exec=$HOME/.local/bin/lidut --hidden|" \
  "$HOME/.local/share/applications/lidut.desktop" > "$HOME/.config/autostart/lidut.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# 4. (Re)start it in the top bar
pkill -f "$HOME/.local/bin/lidut" 2>/dev/null || true
nohup "$HOME/.local/bin/lidut" --hidden >/dev/null 2>&1 &
echo "Installed. Lidut is in your top bar and your app menu."
echo "Optional per-app tracking: sudo ./install-app-tracking.sh"
