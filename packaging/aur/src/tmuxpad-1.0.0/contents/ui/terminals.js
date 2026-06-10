// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT
.pragma library

// Known terminals and how to launch `tmux attach -t <session>` in each.
// %1 is replaced with the (shell-quoted) session name by attachSession().
// Order = auto-pick priority (first installed one wins).
// Two launch styles:
//   argv-style  — the command + args are passed as separate argv (no quoting)
//   string-style— the command is one argument, wrapped in double quotes so the
//                 single-quoted session name nests correctly
var CATALOG = [
    { id: "konsole",         label: "Konsole",          template: "konsole -e tmux attach -t %1" },
    { id: "ghostty",         label: "Ghostty",          template: "ghostty -e tmux attach -t %1" },
    { id: "kitty",           label: "kitty",            template: "kitty tmux attach -t %1" },
    { id: "wezterm",         label: "WezTerm",          template: "wezterm start -- tmux attach -t %1" },
    { id: "alacritty",       label: "Alacritty",        template: "alacritty -e tmux attach -t %1" },
    { id: "foot",            label: "foot",             template: "foot tmux attach -t %1" },
    { id: "gnome-terminal",  label: "GNOME Terminal",   template: "gnome-terminal -- tmux attach -t %1" },
    { id: "ptyxis",          label: "Ptyxis",           template: "ptyxis -- tmux attach -t %1" },
    { id: "kgx",             label: "GNOME Console",    template: "kgx -e \"tmux attach -t %1\"" },
    { id: "xfce4-terminal",  label: "Xfce Terminal",    template: "xfce4-terminal -e \"tmux attach -t %1\"" },
    { id: "tilix",           label: "Tilix",            template: "tilix -e \"tmux attach -t %1\"" },
    { id: "terminator",      label: "Terminator",       template: "terminator -e \"tmux attach -t %1\"" },
    { id: "qterminal",       label: "QTerminal",        template: "qterminal -e \"tmux attach -t %1\"" },
    { id: "deepin-terminal", label: "Deepin Terminal",  template: "deepin-terminal -e tmux attach -t %1" },
    { id: "cool-retro-term", label: "Cool Retro Term",  template: "cool-retro-term -e tmux attach -t %1" },
    { id: "xterm",           label: "xterm",            template: "xterm -e tmux attach -t %1" },
    { id: "st",              label: "st",               template: "st -e tmux attach -t %1" },
    { id: "urxvt",           label: "rxvt-unicode",     template: "urxvt -e tmux attach -t %1" }
];

function ids() {
    return CATALOG.map(function (t) { return t.id; });
}
function byId(id) {
    for (var i = 0; i < CATALOG.length; i++)
        if (CATALOG[i].id === id)
            return CATALOG[i];
    return null;
}
function template(id) {
    var t = byId(id);
    return t ? t.template : "";
}
function label(id) {
    var t = byId(id);
    return t ? t.label : id;
}
