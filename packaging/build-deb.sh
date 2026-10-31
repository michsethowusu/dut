#!/usr/bin/env bash
# Builds dist/dut_<version>_all.deb.  Usage: packaging/build-deb.sh [version]
# Version defaults to __version__ in the dut script.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-$(python3 -c "import re;print(re.search(r'__version__ = \"(.+?)\"', open('dut').read()).group(1))")}"
VERSION="${VERSION#v}"
PKG="dut_${VERSION}_all"
ROOT="$(mktemp -d)/$PKG"
trap 'rm -rf "$(dirname "$ROOT")"' EXIT

install -Dm755 dut                     "$ROOT/usr/bin/dut"
sed -i "s/^__version__ = .*/__version__ = \"$VERSION\"/" "$ROOT/usr/bin/dut"
install -Dm755 dut-collector           "$ROOT/usr/lib/dut/dut-collector"
install -Dm644 packaging/dut-apps.service "$ROOT/lib/systemd/system/dut-apps.service"
install -Dm644 packaging/dut.desktop   "$ROOT/usr/share/applications/dut.desktop"
install -d "$ROOT/etc/xdg/autostart"
sed 's/^Exec=dut$/Exec=dut --hidden/' packaging/dut.desktop > "$ROOT/etc/xdg/autostart/dut.desktop"
chmod 644 "$ROOT/etc/xdg/autostart/dut.desktop"
install -Dm644 README.md               "$ROOT/usr/share/doc/dut/README.md"
install -Dm644 LICENSE                 "$ROOT/usr/share/doc/dut/copyright"

install -d "$ROOT/DEBIAN"
SIZE=$(du -sk --exclude=DEBIAN "$ROOT" | cut -f1)
sed -e "s/@VERSION@/$VERSION/" -e "s/@SIZE@/$SIZE/" packaging/debian/control > "$ROOT/DEBIAN/control"
echo "/etc/xdg/autostart/dut.desktop" > "$ROOT/DEBIAN/conffiles"
chmod 644 "$ROOT/DEBIAN/conffiles"
for s in postinst prerm postrm; do install -m755 "packaging/debian/$s" "$ROOT/DEBIAN/$s"; done

mkdir -p dist
dpkg-deb --root-owner-group -Zxz --build "$ROOT" "dist/$PKG.deb" >/dev/null
echo "dist/$PKG.deb"
