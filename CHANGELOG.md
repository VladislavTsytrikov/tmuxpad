# Changelog

## 1.0.0 — 2026-06-10

First public release.

- AI agent status per tmux session: working / waiting for input / idle
  (pane-title Braille spinner + configurable regex patterns)
- Agent detection by foreground command and by process-tree command line,
  so runtime-wrapped installs (`node cli.js`, `python -m aider`) are recognised
- Desktop notifications on working → waiting and working → finished
  transitions (detached sessions only)
- Output preview for any session without attaching
- Compact panel representation with attention badge,
  `NeedsAttention` panel status when an agent waits for input
- Attach / create / kill sessions
- English UI with Russian translation (gettext)
