#!/usr/bin/env bash
# One-time AUR publish for plasma6-applet-tmuxpad.
#
# Prerequisites (do these once, in your browser):
#   1. Create an AUR account:  https://aur.archlinux.org/register
#   2. Add your SSH *public* key under  My Account → SSH Public Key  and Save.
#      (the key whose private half lives on this machine, e.g. ~/.ssh/id_ed25519.pub)
#
# Then just run:  ./publish.sh
set -euo pipefail

PKG=plasma6-applet-tmuxpad
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "→ Verifying SSH access to the AUR…"
if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new aur@aur.archlinux.org help 2>&1 | grep -qi 'interactive shell is disabled\|Welcome'; then
  echo "  Could not authenticate to aur@aur.archlinux.org."
  echo "  Register + add your SSH public key first (see the header of this script)."
  exit 1
fi

echo "→ Cloning the (empty) AUR repo…"
git clone "ssh://aur@aur.archlinux.org/$PKG.git" "$WORK/$PKG"

cp "$HERE/PKGBUILD" "$HERE/.SRCINFO" "$WORK/$PKG/"
cd "$WORK/$PKG"
git add PKGBUILD .SRCINFO
git -c user.name="Vlad Tsytrikov" -c user.email="vladislavtsytrikov@gmail.com" \
    commit -m "Initial import: plasma6-applet-tmuxpad 1.0.1"
git push origin master

echo "✓ Published! https://aur.archlinux.org/packages/$PKG"
