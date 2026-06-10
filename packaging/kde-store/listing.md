# KDE Store (store.kde.org) submission

The KDE Store is what **Add Widgets → Get New Widgets** pulls from inside Plasma —
the single highest-discovery channel for a plasmoid. Upload is a web form and needs
your opendesktop.org / KDE Store login (it's the same account as the rest of KDE).

## How to upload

1. Sign in at <https://store.kde.org> (top-right). Create the account if needed.
2. **My Products → Add Product**.
3. **Category:** *Plasma 6 → Plasma 6 Applets* (a.k.a. Plasmoids).
4. Fill the fields with the copy below.
5. Upload the package file: `tmuxpad-1.0.1.plasmoid` (built with `make package`).
6. Upload the images from this repo:
   - `assets/banner.png`   (cover / first image)
   - `screenshots/hero.png`
   - `screenshots/demo.gif` (animated preview)
7. Set the homepage to `https://github.com/VladislavTsytrikov/tmuxpad`, license **MIT**.
8. Publish.

> On every new release: bump the version and upload the new `.plasmoid` under
> **Files** for the same product (keeps ratings/downloads).

---

## Title

TmuxPad — Mission Control for AI Coding Agents in tmux

## Summary (one line)

See which of your AI coding agents (Claude Code, aider, codex…) is working, waiting for you, or idle — at a glance.

## Tags

tmux, ai, claude, agents, monitor, session, terminal, productivity, dashboard, notifications

## Description (English)

**TmuxPad is a KDE Plasma 6 widget that monitors your tmux sessions and the AI coding agents running inside them.** It detects, in real time, whether each agent is **working**, **waiting for your input**, or **idle**, and surfaces the ones that need you — so you keep a whole fleet of agents productive without babysitting terminals.

If you "vibe code" with several agents at once — one refactoring, one writing tests, one stuck on a permission prompt — TmuxPad tells you, at a glance, who needs you right now.

Features
• Live agent status: working / waiting for input / idle, grouped so blocked agents float to the top
• Quick reply — hit y / n / Enter for a waiting agent straight from the card, without attaching
• Desktop notifications the moment an agent stops working and needs you
• Glanceable output — the last line each agent printed, right on the card
• "Waiting 12 min" elapsed time so you see who's been blocked longest
• One-click attach in your terminal of choice (auto-detected)
• One button drops a full dashboard onto your desktop
• Native & themed — follows your Plasma theme, no hardcoded colors

Works with Claude Code out of the box; aider, codex, opencode, gemini, goose, crush and others are detected as agents. Detection patterns are editable in the settings — one line of regex, no waiting for a release.

Requirements: KDE Plasma 6, tmux 1.9+.
Source & issues: https://github.com/VladislavTsytrikov/tmuxpad

## Description (Русский)

**TmuxPad — виджет KDE Plasma 6, который следит за tmux-сессиями и AI-агентами внутри них.** В реальном времени определяет, что делает каждый агент — **работает**, **ждёт твоего ответа** или **простаивает** — и поднимает наверх тех, кому ты сейчас нужен. Целый флот агентов остаётся продуктивным без постоянного переключения между терминалами.

Возможности
• Живой статус агента: работает / ждёт ввода / простаивает, заблокированные всплывают наверх
• Быстрый ответ — y / n / Enter прямо с карточки, без подключения
• Уведомления на рабочий стол в момент, когда агент перестал работать и ждёт тебя
• Превью вывода — последняя строка агента прямо на карточке
• «Ждёт 12 мин» — видно, кто завис дольше всех
• Подключение в один клик в твоём терминале (определяется автоматически)
• Одна кнопка кладёт полноценный дашборд на рабочий стол
• Нативно и по теме Plasma — никаких захардкоженных цветов

Из коробки работает с Claude Code; aider, codex, opencode, gemini, goose, crush и другие распознаются как агенты. Паттерны детекта правятся в настройках одной строкой regex.

Требования: KDE Plasma 6, tmux 1.9+.
Исходники: https://github.com/VladislavTsytrikov/tmuxpad
