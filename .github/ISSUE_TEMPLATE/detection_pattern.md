---
name: Detection pattern request
about: A tool shows the wrong status (idle when working, etc.)
title: "[detection] <tool name>"
labels: detection
---

**Tool / agent**
e.g. aider 0.x, codex, opencode…

**How is it launched in tmux?**
e.g. `aider`, `python -m aider`, `node cli.js`

**What does it print while WORKING?**
Paste a representative line (the bottom of the pane while it's busy).

**What does it print while WAITING for your input?**
Paste the prompt line (e.g. `Apply changes? (y/n)`).

**Suggested regex (if you have one)**
- working: `...`
- waiting: `...`

**Does it set a pane title?** (run `tmux display -p '#{pane_title}'` while it's busy)
