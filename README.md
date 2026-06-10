# TmuxPad

**Your AI coding agents, on your desktop.** A KDE Plasma 6 widget that watches your tmux sessions and shows, at a glance, which agent is working, which one is waiting for your answer, and which is idle — and lets you reply or jump in without hunting through terminals.

[![CI](https://github.com/VladislavTsytrikov/tmuxpad/actions/workflows/ci.yml/badge.svg)](https://github.com/VladislavTsytrikov/tmuxpad/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

![TmuxPad widget](screenshots/hero.png)

In the panel it collapses to a single icon with a badge that **pulses orange when an agent is waiting for you**.

## Why

If you run Claude Code, codex, aider or any other coding agent in tmux, you know the drill: you spin up three agents, switch to something else, and twenty minutes later discover that one of them has been sitting on a *"Do you want to proceed? (y/n)"* prompt the whole time.

TmuxPad is mission control for your fleet of agents:

- 🟢 **Live status per session** — *working*, *waiting for input*, or *idle*, grouped so the ones that need you float to the top
- ⏳💬 **Quick reply** — answer **y / n / Enter** to a waiting agent straight from the card, no need to attach
- 🔔 **Desktop notifications** — when an agent stops working and needs you, or finishes its task
- 👀 **Glanceable output** — the last line each agent printed, right on the card; expand for a full preview
- ⏱️ **Elapsed time** — "waiting 12 min" so you know who's been blocked longest
- ⚡ **One-click attach** — opens the session in your terminal of choice (auto-detected)
- ➕ **Create & kill sessions** from the widget
- 🎛️ **Panel mode** — compact icon with an attention badge

It's also a perfectly good plain tmux session manager — sessions without an agent are listed under *Terminals*.

## How status detection works

TmuxPad polls tmux every few seconds (configurable) in a single batched call:

1. **Pane title spinner.** Claude Code animates a Braille spinner (`⠋⠙⠹…`) in the pane title while busy. If the title starts with one, the agent is **working** — set via an OSC escape, so it works regardless of your tmux `set-titles` / `allow-rename` settings.
2. **Content patterns.** The last visible lines of each session are matched against configurable regex lists:
   - *waiting*: `Do you want`, `❯ 1.`, `(y/n)`, `[Y/n]`, `Press Enter to`, …
   - *working*: `esc to interrupt`, the Claude Code progress line, …
3. **Agent detection.** A session counts as an agent when its foreground process is a known tool (`claude`, `codex`, `aider`, `opencode`, `gemini`, `goose`, `amp`, `crush`, `cursor-agent` — editable), **or** when it's launched through a runtime like `node cli.js` / `python -m aider`. The pane's process tree is read from `/proc` (portable, no procps-only flags), so wrapped installs are recognised too.

All three lists live in the widget's settings — when a tool changes its UI or a new one appears, you fix it with a one-line regex instead of waiting for a release.

Notifications fire only on transitions out of *working*, and only for **detached** sessions — if you're attached, you already see what's happening.

## Install

### KDE Store

*Coming soon* — search for "TmuxPad" in **Add Widgets → Get New Widgets**.

### From source

```bash
git clone https://github.com/VladislavTsytrikov/tmuxpad.git
cd tmuxpad
make install        # installs the widget + translations for the current user
```

Then add **TmuxPad** to your desktop or panel. Update later with `git pull && make install`.

Requirements: KDE Plasma 6, tmux. Building translations needs `gettext`.

## Settings

Open the settings straight from the popup (the **gear** slides a panel in), or right-click → Configure for the system dialog.

- **Terminal** — TmuxPad scans your machine for installed terminals (Konsole, Ghostty, kitty, WezTerm, Alacritty, foot, GNOME Terminal, Tilix, …) and lets you pick one from a dropdown, with a live preview of the launch command. *Automatic* just uses the first one it finds — zero config. *Custom command* is there for anything exotic.
- **Updates** — refresh interval and how many output lines to capture.
- **Notifications** — toggle the *waiting* and *finished* notifications.
- **AI Agents** — the process names and the *working* / *waiting* regex patterns.

## Compatibility

| Works | Notes |
|---|---|
| **Plasma 6.0+**, X11 & Wayland | uses only stable Plasma 6 APIs |
| **tmux 1.9+** | `display-message`, `capture-pane`, `pane_pid` are long-standing |
| **Claude Code** | full status detection out of the box |
| **aider / codex / opencode / others** | recognised as agents; *waiting* detection works via the shared prompts, *working* may need a pattern tuned to that tool's UI (one line in settings) |
| Terminal emulator | auto-detected; ~18 known, plus a custom command |

Known limits: only the **active pane of each session's active window** is inspected (an agent buried in a background window shows as idle), and a desktop-placed widget pauses its timer while the desktop is fully covered — **for always-on background notifications, put TmuxPad in a panel**, where the timer never sleeps. Notifications need `org.kde.notification` (present on standard Plasma installs); without it the widget still works, just silently.

## Roadmap

- Per-window status for multi-window sessions (the orchestrator pattern)
- cwd + git branch on each card
- More built-in detection profiles as agent CLIs evolve

Issues and PRs welcome — especially [detection patterns](.github/ISSUE_TEMPLATE/detection_pattern.md) for tools you use. See [CONTRIBUTING](CONTRIBUTING.md).

## Related

- [TmuxRunner](https://github.com/alex1701c/TmuxRunner) — KRunner plugin: attach to tmux sessions from Alt+Space. Great companion, different job.

## License

[MIT](LICENSE) © Vlad Tsytrikov
