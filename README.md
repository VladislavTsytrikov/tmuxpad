# TmuxPad

**Your AI coding agents, on your desktop.** A KDE Plasma 6 widget that watches tmux sessions and tells you which of your agents is working, which one is waiting for your answer — and lets you jump in with one click.

![TmuxPad widget](screenshots/hero.png)

In the panel it collapses to a single icon with a badge — **orange means an agent is waiting for you**, blue is the number of running agents.

## Why

If you run Claude Code, codex, aider or any other coding agent in tmux, you know the drill: you spin up three agents, switch to something else, and twenty minutes later discover that one of them has been sitting on a "Do you want to proceed?" prompt the whole time.

TmuxPad fixes that:

- 🟢 **Live status per session** — *working*, *waiting for input*, or *idle*, right on your desktop or panel
- 🔔 **Desktop notifications** — when an agent stops working and needs your answer, or finishes its task
- 👀 **Output preview** — peek at the last lines of any session without attaching
- ⚡ **One-click attach** — opens the session in your terminal of choice
- ➕ **Create & kill sessions** from the widget
- 🎛️ **Panel mode** — compact icon with a badge: orange means someone needs you

It is also a perfectly good plain tmux session manager — sessions without an agent are listed too.

## How status detection works

TmuxPad polls tmux once every 3 seconds (configurable), in a single batched `tmux` call:

1. **Pane title spinner.** Claude Code animates a Braille spinner (`⠋⠙⠹…`) in the pane title while busy. If the title starts with one — the agent is **working**. This is set via an OSC escape, so it works regardless of your tmux `set-titles` / `allow-rename` settings.
2. **Content patterns.** The last visible lines of each session are matched against configurable regex lists:
   - *waiting*: `Do you want`, `❯ 1.`, `(y/n)`, `[Y/n]`, `Press Enter to`, …
   - *working*: `esc to interrupt`, the Claude Code progress line, …
3. **Agent detection.** A session counts as an agent session when its foreground process is one of the known tools (`claude`, `codex`, `aider`, `opencode`, `gemini`, `goose`, `amp`, `crush`, `cursor-agent` — editable), **or** when it is launched through a runtime like `node cli.js` / `python -m aider` (the command line of the pane's process tree is inspected, so wrapped installs are recognised too).

All three lists live in widget settings (**AI Agents** page) — when your favourite tool changes its UI or a new one appears, you fix it with a one-line regex instead of waiting for a release.

Notifications fire only on transitions out of *working* and only for **detached** sessions — if you are attached, you already see what's happening.

## Install

### KDE Store

*Coming soon* — search for "TmuxPad" in **Add Widgets → Get New Widgets**.

### From source

```bash
git clone https://github.com/VladislavTsytrikov/tmuxpad.git
cd tmuxpad
make install        # installs the widget + translations for current user
```

Then add **TmuxPad** to your desktop or panel. To update later: `git pull && make upgrade`.

Requirements: KDE Plasma 6, tmux. Translations need `gettext` at build time.

## Configuration

| Setting | Default | |
|---|---|---|
| Attach command | `konsole -e tmux attach -t %1` | `%1` = session name; works with wezterm, ghostty, alacritty, … |
| Refresh interval | 3 s | |
| Preview lines | 12 | also used for status detection depth |
| Notifications | on | waiting / finished, separately |
| Agent processes & patterns | see above | **AI Agents** settings page |

## Compatibility

| Works | Notes |
|---|---|
| **Plasma 6.0+**, X11 & Wayland | uses only stable Plasma 6 APIs |
| **tmux 1.9+** | `display-message`, `capture-pane`, `pane_pid` are long-standing |
| **Claude Code** | full status detection out of the box |
| **aider / codex / opencode / others** | recognised as agents; *waiting* detection works via the shared prompts, *working* may need a pattern tuned to that tool's UI (one line in settings) |
| Terminal emulator | any — set the attach command for konsole / wezterm / ghostty / alacritty / kitty / … |

Known limits: only the **active pane of each session's active window** is inspected (an agent buried in a background window shows as idle), and a desktop-placed widget pauses its timer while the desktop is fully covered — **for always-on background notifications, put TmuxPad in a panel**, where the timer never sleeps. Notifications need `org.kde.notification` (present on standard Plasma installs); without it the widget still works, just silently.

## Roadmap

- **Quick reply** — approve an agent's permission prompt right from the widget (`tmux send-keys`)
- Per-window status for multi-window sessions
- More built-in detection profiles as agent CLIs evolve

Issues and PRs welcome — especially detection patterns for tools you use.

## Related

- [TmuxRunner](https://github.com/alex1701c/TmuxRunner) — KRunner plugin: attach to tmux sessions from Alt+Space. Great companion, different job.

## License

[MIT](LICENSE)
