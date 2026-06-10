# Changelog

## 1.0.0 — 2026-06-10

First public release.

- AI agent status per tmux session: working / waiting for input / idle
  (pane-title Braille spinner + configurable regex patterns)
- Agent detection by foreground command and by process-tree command line,
  read from `/proc` (portable, no procps-only `ps` flags), so runtime-wrapped
  installs (`node cli.js`, `python -m aider`) are recognised
- Mission-Control UI: sessions grouped into status buckets (needs-you /
  working / idle / terminals) as cards with colour avatars, live Braille
  spinner, glow on waiting, glanceable last-output line, and elapsed time
  (waiting sorted longest-blocked first)
- Quick-reply: answer y / n / Enter to a waiting agent without attaching
- Desktop notifications on working → waiting and working → finished
  transitions (detached sessions only)
- Output preview for any session without attaching
- Compact panel representation with pulsing attention badge,
  `NeedsAttention` panel status when an agent waits for input
- Terminal auto-detection — scans for ~18 known terminals and offers a picker
  with a live command preview; "Automatic" needs no configuration
- In-widget settings panel in the same style (gear in the popup), plus the
  system config dialog as a fallback
- Attach / create / kill sessions
- Stable ListModel with diff-by-name updates, so cards (and their dialogs /
  open previews) survive every poll without flicker
- English UI with Russian translation (bundled in the package)
