# AUR package — `plasma6-applet-tmuxpad`

Files here build the [Arch User Repository](https://aur.archlinux.org/) package for
TmuxPad. Works on Arch, **CachyOS**, Manjaro, EndeavourOS, and other Arch-based distros.

## Install (for users)

```bash
# with an AUR helper
paru -S plasma6-applet-tmuxpad
# or
yay -S plasma6-applet-tmuxpad
```

Then add the widget: right-click the desktop or panel → **Add Widgets** → search *TmuxPad*.

## Build locally

```bash
makepkg -si        # build and install
namcap *.pkg.tar.zst   # lint (optional)
```

## Maintainer: cutting a new release

After tagging a new `vX.Y.Z` on GitHub:

```bash
sed -i "s/^pkgver=.*/pkgver=X.Y.Z/" PKGBUILD
updpkgsums                       # refresh sha256 from the new tarball
makepkg -f                       # verify it builds
makepkg --printsrcinfo > .SRCINFO
git -C "$AUR_CLONE" commit -am "Update to X.Y.Z" && git -C "$AUR_CLONE" push
```

`.SRCINFO` must be regenerated and committed on every change — the AUR rejects pushes without it.
