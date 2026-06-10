#!/usr/bin/env sh
# TmuxPad one-line installer — downloads the latest .plasmoid from GitHub
# Releases and installs it. No git clone, no build step.
#
#   curl -fsSL https://raw.githubusercontent.com/VladislavTsytrikov/tmuxpad/main/install.sh | sh
#
set -eu

REPO="VladislavTsytrikov/tmuxpad"
ID="org.tsy.tmuxpad"

say()  { printf '\033[1;34m→\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$1" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required."
command -v kpackagetool6 >/dev/null 2>&1 || die "kpackagetool6 not found — this needs KDE Plasma 6."
command -v tmux >/dev/null 2>&1 || printf '\033[1;33m!\033[0m tmux not found — install it to actually use TmuxPad.\n'

say "Finding the latest TmuxPad release…"
URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o '"browser_download_url"[^,]*\.plasmoid"' \
  | head -1 | cut -d'"' -f4)
[ -n "${URL:-}" ] || die "Couldn't find a .plasmoid asset in the latest release."

TMPDIR_T=$(mktemp -d)
trap 'rm -rf "$TMPDIR_T"' EXIT
PKG="$TMPDIR_T/tmuxpad.plasmoid"

say "Downloading…"
curl -fsSL "$URL" -o "$PKG"

say "Installing…"
if kpackagetool6 -t Plasma/Applet -i "$PKG" 2>/dev/null; then
  ok "TmuxPad installed."
elif kpackagetool6 -t Plasma/Applet -u "$PKG" 2>/dev/null; then
  ok "TmuxPad updated."
else
  die "kpackagetool6 failed to install the package."
fi

printf '\n'
ok "Done! Now add it to your desktop or panel:"
printf '   right-click the desktop or panel  →  Add Widgets  →  search \033[1mTmuxPad\033[0m\n'
printf '   (tip: drop it on the desktop for a full mission-control dashboard)\n'
