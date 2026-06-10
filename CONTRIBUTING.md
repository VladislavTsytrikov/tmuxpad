# Contributing to TmuxPad

Thanks for helping out! TmuxPad is a small QML/Plasma 6 widget, so the loop is quick.

## Build & run locally

```bash
make install        # installs the widget + translations for the current user
# then add "TmuxPad" to a panel (right click → Add Widgets)
```

After editing QML you usually just need to reload the plasmoid. The most reliable way:

```bash
systemctl --user restart plasma-plasmashell.service
```

> **Don't** run `kpackagetool6 -u .` from inside the installed directory — it removes the folder before reinstalling and the source path *is* the install path. Use `make install` / a plasmashell restart instead.

You can also preview the widget standalone (needs `plasma-sdk`):

```bash
plasmoidviewer -a .
```

## Detection patterns

The most welcome contribution is **status-detection patterns for tools you use** (aider, codex, opencode, gemini, …). The widget detects *working* / *waiting* from the pane title (Braille spinner) and regexes matched against pane output — see the **AI Agents** settings page and `contents/config/main.xml`.

If a tool of yours shows the wrong status, open an issue with: the tool, what it prints when working vs waiting, and a regex that matches. There's an issue template for exactly this.

## Translations

```bash
make pot                 # refresh po/plasma_applet_org.tsy.tmuxpad.pot
# add/update po/<lang>.po
make install-translations
msgfmt -c po/<lang>.po   # validate
```

UI strings are wrapped in `i18nd("plasma_applet_org.tsy.tmuxpad", "...")`. Keep the English source in the source files; translate in `po/`.

## Style

- All colours and sizes come from `Kirigami.Theme.*` / `Kirigami.Units.*` — never hardcode, so the widget follows the user's theme.
- No new external QML dependencies without discussion (the widget aims to run on any Plasma 6 install).
- Run `qmllint contents/ui/*.qml` before opening a PR.

## License

By contributing you agree your work is licensed under the MIT License, and you add the SPDX headers to any new file:

```
// SPDX-FileCopyrightText: <year> <you>
// SPDX-License-Identifier: MIT
```
