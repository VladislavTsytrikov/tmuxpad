// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * TmuxPad — tmux session manager and AI agent monitor for KDE Plasma 6.
 *
 * Polls `tmux display-message` + `capture-pane` in one batch command, derives
 * a per-session agent status (working / waiting for input / idle) from the
 * pane title and configurable regex rules, and notifies on status changes.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import "terminals.js" as Terminals

PlasmoidItem {
    id: root

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    // [{name, windows, attached, created, tool, status, content}]
    // status: "waiting" | "working" | "idle" (agent present) | "none" (plain shell)
    property var sessions: []
    property bool serverUp: false
    property bool firstLoad: true
    // session name -> last seen status, for transition notifications
    property var prevStatuses: ({})
    // session name -> epoch ms when it entered its current status
    property var statusSince: ({})

    readonly property int waitingCount: sessions.filter(s => s.status === "waiting").length
    readonly property int workingCount: sessions.filter(s => s.status === "working").length
    readonly property int idleCount: sessions.filter(s => s.status === "idle").length
    readonly property int agentCount: sessions.filter(s => s.status !== "none").length

    // animated Braille spinner shared by all "working" cards
    property int spinnerFrame: 0
    readonly property var spinnerFrames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    readonly property string spinnerGlyph: spinnerFrames[spinnerFrame % spinnerFrames.length]

    // ticks every 15s so "waiting 12 min" keeps counting without a data change
    property int nowTick: 0

    // status -> bucket index (sort/section order): waiting, working, idle, plain
    function bucket(status) {
        return status === "waiting" ? 0 : status === "working" ? 1 : status === "idle" ? 2 : 3;
    }

    // Stable-identity model for the cards. We diff by session name so the same
    // ListModel row (and therefore the same delegate, with its confirming /
    // preview state) is reused across polls instead of being recreated — no
    // flicker, no replayed entrance animation, no lost dialogs.
    // Exposed via alias so the full representation (another file) can bind to it.
    property alias sessionsModel: sessionsModelImpl
    ListModel { id: sessionsModelImpl }

    function syncModel(list) {
        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            var j = -1;
            for (var k = i; k < sessionsModel.count; k++) {
                if (sessionsModel.get(k).name === item.name) { j = k; break; }
            }
            if (j === -1)
                sessionsModel.insert(i, item);
            else {
                if (j !== i)
                    sessionsModel.move(j, i, 1);
                sessionsModel.set(i, item);
            }
        }
        while (sessionsModel.count > list.length)
            sessionsModel.remove(sessionsModel.count - 1);
    }

    // terminals installed on this machine (subset of the catalog), found by scan
    property var availableTerminals: []
    readonly property string autoTerminalId: availableTerminals.length ? availableTerminals[0] : ""

    // the actual attach command for the current setting: a catalog template for
    // a chosen/auto terminal, or the user's custom command
    readonly property string terminalCmd: {
        var id = Plasmoid.configuration.terminalId;
        if (id === "custom")
            return Plasmoid.configuration.terminalCommand;
        if (id === "auto")
            return autoTerminalId ? Terminals.template(autoTerminalId)
                                  : Plasmoid.configuration.terminalCommand;
        return Terminals.template(id) || Plasmoid.configuration.terminalCommand;
    }

    function scanTerminals() {
        var cmd = "for t in " + Terminals.ids().join(" ")
            + "; do command -v \"$t\" >/dev/null 2>&1 && printf '%s\\n' \"$t\"; done";
        exec.run(cmd, function (code, out) {
            root.availableTerminals = out.split("\n").map(l => l.trim()).filter(l => l.length > 0);
        });
    }

    readonly property int refreshSec: Math.max(1, Plasmoid.configuration.refreshInterval)
    readonly property int captureLines: Math.max(15, Plasmoid.configuration.previewLines)

    readonly property var agentTools: splitLines(Plasmoid.configuration.agentCommands)
    readonly property var workingRes: compileRes(Plasmoid.configuration.workingPatterns)
    readonly property var waitingRes: compileRes(Plasmoid.configuration.waitingPatterns)

    Plasmoid.title: "TmuxPad"
    Plasmoid.icon: "utilities-terminal"
    Plasmoid.status: waitingCount > 0 ? PlasmaCore.Types.NeedsAttentionStatus
                   : sessions.length > 0 ? PlasmaCore.Types.ActiveStatus
                   : PlasmaCore.Types.PassiveStatus

    toolTipMainText: "TmuxPad"
    toolTipSubText: !serverUp ? i18nd(i18nDomain, "tmux server is not running")
        : waitingCount > 0 ? i18ndp(i18nDomain, "%1 agent needs your input", "%1 agents need your input", waitingCount)
        : workingCount > 0 ? i18ndp(i18nDomain, "%1 agent working", "%1 agents working", workingCount)
        : i18ndp(i18nDomain, "%1 session", "%1 sessions", sessions.length)

    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar
        ? fullRepresentation : compactRepresentation
    compactRepresentation: CompactRepresentation { plasmoidItem: root }
    fullRepresentation: FullRepresentation { plasmoidItem: root }

    // ───────────────────────── backend ─────────────────────────
    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        property var cbs: ({})
        onNewData: (source, data) => {
            var cb = cbs[source];
            if (cb)
                cb((data["exit code"] || 0), (data["stdout"] || ""), (data["stderr"] || ""));
            delete cbs[source];
            disconnectSource(source);
        }
        function run(cmd, cb) {
            if (cmd in cbs)
                return;            // the same command is still running
            cbs[cmd] = cb || null;
            connectSource(cmd);
        }
    }

    function splitLines(s) {
        return String(s || "").split("\n").map(l => l.trim()).filter(l => l.length > 0);
    }

    function compileRes(s) {
        var out = [];
        var lines = splitLines(s);
        for (var i = 0; i < lines.length; i++) {
            try {
                out.push(new RegExp(lines[i]));
            } catch (e) { /* skip invalid user regex */ }
        }
        return out;
    }

    // Interpreters that launch an agent as an argument (e.g. `node cli.js`,
    // `python -m aider`). Used to recognise agents whose foreground command
    // is the runtime rather than the tool itself, without false-matching a
    // pager/editor that merely has an agent's name in its path.
    readonly property var interpreters: ["node", "nodejs", "python", "python3",
        "bun", "deno", "npx", "ruby", "php", "perl", "uv", "uvx"]

    function basename(tok) {
        return String(tok || "").replace(/^-/, "").split("/").pop().toLowerCase();
    }

    // A session counts as an agent when its foreground command, the basename
    // of its executable, or (for interpreters) any argument names a known tool.
    function isAgent(cmd, args) {
        if (agentTools.indexOf(String(cmd || "").toLowerCase()) !== -1)
            return true;
        var toks = String(args || "").trim().split(/\s+/);
        if (!toks.length || !toks[0])
            return false;
        var exe = basename(toks[0]);
        if (agentTools.indexOf(exe) !== -1)
            return true;
        if (interpreters.indexOf(exe) !== -1) {
            for (var i = 0; i < agentTools.length; i++) {
                var re = new RegExp("(^|[^a-z0-9])" + agentTools[i].replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "([^a-z0-9]|$)", "i");
                if (re.test(args))
                    return true;
            }
        }
        return false;
    }

    // Claude Code (and some other TUIs) animate a Braille spinner
    // (U+2800–U+28FF) as the first character of the pane title while busy.
    function titleBusy(title) {
        if (!title || !title.length)
            return false;
        var c = title.charCodeAt(0);
        return c >= 0x2800 && c <= 0x28FF;
    }

    function computeStatus(tool, title, args, content) {
        if (!isAgent(tool, args))
            return "none";
        for (var i = 0; i < waitingRes.length; i++)
            if (waitingRes[i].test(content))
                return "waiting";
        if (titleBusy(title))
            return "working";
        for (i = 0; i < workingRes.length; i++)
            if (workingRes[i].test(content))
                return "working";
        return "idle";
    }

    // Record separators chosen from the ASCII C0 control range so they cannot
    // collide with session names, command lines or captured output (none of
    // which contain these bytes in practice). US between fields, RS before the
    // captured content, EOR between sessions.
    readonly property string fieldSep: "\x1f"
    readonly property string contentSep: "\x1e"
    readonly property string recordSep: "\x1d"

    // One shell round-trip per tick. For each session we read the active pane
    // of its active window (display-message targets it directly), the command
    // lines of that pane's process and its children (for agent detection that
    // survives `node cli.js` / `python -m tool` launches), and the visible
    // output (for status patterns + preview). Process command lines come from
    // /proc (portable across coreutils/busybox; no procps-only `ps` flags).
    // Control bytes are stripped from args/content so they can never break the
    // framing above; pane_title is stripped too in case an app injects them.
    readonly property string batchCmd:
        "U=$(printf '\\037'); R=$(printf '\\036'); E=$(printf '\\035'); "
        + "tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r s; do "
        + "m=$(tmux display-message -p -t \"$s\" -F \"#{pane_current_command}${U}#{pane_title}${U}#{session_windows}${U}#{session_attached}${U}#{session_created}${U}#{pane_pid}\" 2>/dev/null); "
        + "p=${m##*${U}}; "
        + "a=''; if [ -n \"$p\" ]; then "
        + "a=$(cat /proc/$p/cmdline 2>/dev/null | tr '\\0' ' '); "
        + "for ch in $(cat /proc/$p/task/$p/children 2>/dev/null); do a=\"$a $(cat /proc/$ch/cmdline 2>/dev/null | tr '\\0' ' ')\"; done; "
        + "a=$(printf '%s' \"$a\" | tr -d \"${U}${R}${E}\"); fi; "
        + "c=$(tmux capture-pane -p -t \"$s\" 2>/dev/null | tr -d \"${U}${R}${E}\"); "
        + "printf '%s%s%s%s%s%s%s%s' \"$s\" \"$U\" \"$m\" \"$U\" \"$a\" \"$R\" \"$c\" \"$E\"; "
        + "done"

    function refresh() {
        exec.run(batchCmd, function (code, out) {
            root.firstLoad = false;
            if (code !== 0) {
                root.serverUp = false;
                root.sessions = [];
                root.prevStatuses = {};
                sessionsModel.clear();
                return;
            }
            root.serverUp = true;
            root.applyOutput(out);
        });
    }

    function applyOutput(out) {
        // Records are EOR-separated; each is "name US cmd US title US windows
        // US attached US created US pid US args RS content".
        var records = out.split(recordSep);
        var list = [];
        var newStatuses = {};
        for (var r = 0; r < records.length; r++) {
            var rec = records[r];
            if (!rec)
                continue;
            var ri = rec.indexOf(contentSep);
            var head = ri >= 0 ? rec.slice(0, ri) : rec;
            var content = ri >= 0 ? rec.slice(ri + 1) : "";
            var f = head.split(fieldSep);
            if (f.length < 6 || !f[0])
                continue;
            content = content.replace(/^\n/, "").replace(/\s+$/, "");
            content = content.split("\n").slice(-captureLines).join("\n");
            var s = {
                "name": f[0],
                "tool": f[1],
                "title": f[2],
                "windows": parseInt(f[3]) || 0,
                "attached": (parseInt(f[4]) || 0) > 0,
                "created": parseInt(f[5]) || 0,
                "content": content
            };
            s.status = computeStatus(s.tool, s.title, f[7] || "", content);
            newStatuses[s.name] = s.status;
            list.push(s);
        }
        // track when each session entered its current status (for "waiting 12 min")
        var now = Date.now();
        var newSince = {};
        for (var k = 0; k < list.length; k++) {
            var nm = list[k].name;
            newSince[nm] = (prevStatuses[nm] === list[k].status && statusSince[nm])
                ? statusSince[nm] : now;
            list[k].since = newSince[nm];
            list[k].bucket = bucket(list[k].status);
        }

        // sort by bucket, then: waiting -> longest-blocked first; else by name
        list.sort(function (a, b) {
            if (a.bucket !== b.bucket)
                return a.bucket - b.bucket;
            if (a.bucket === 0)
                return a.since - b.since;
            return a.name.localeCompare(b.name);
        });

        for (var i = 0; i < list.length; i++)
            maybeNotify(list[i]);

        syncModel(list);
        root.sessions = list;
        root.prevStatuses = newStatuses;
        root.statusSince = newSince;
    }

    // ───────────────────────── notifications ─────────────────────────
    function maybeNotify(s) {
        // only transitions out of "working", and only for detached sessions —
        // if the session is attached the user is already looking at it
        if (prevStatuses[s.name] !== "working" || s.attached)
            return;
        if (s.status === "waiting" && Plasmoid.configuration.notifyOnWaiting)
            notify(i18nd(i18nDomain, "Agent needs your input"),
                   i18nd(i18nDomain, "Session “%1” is waiting for your answer", s.name), s.name);
        else if (s.status === "idle" && Plasmoid.configuration.notifyOnDone)
            notify(i18nd(i18nDomain, "Agent finished"),
                   i18nd(i18nDomain, "Session “%1” is idle again", s.name), s.name);
    }

    function notify(title, text, sessionName) {
        if (notifLoader.status === Loader.Ready)
            notifLoader.item.send(title, text, sessionName);
    }

    // org.kde.notification may be missing on minimal setups; degrade gracefully
    Loader {
        id: notifLoader
        source: "NotificationHelper.qml"
    }
    Connections {
        target: notifLoader.item
        enabled: notifLoader.status === Loader.Ready
        function onAttachRequested(name) {
            root.attachSession(name);
        }
    }

    // ───────────────────────── actions ─────────────────────────
    function attachSession(name) {
        var base = terminalCmd.indexOf("%1") >= 0 ? terminalCmd.replace(/%1/g, shq(name)) : (terminalCmd + " " + shq(name));
        // setsid -f: detach the terminal so it outlives plasmashell
        exec.run("setsid -f " + base + " >/dev/null 2>&1", null);
    }

    function newSession(name) {
        var n = sanitize(name);
        if (!n)
            return;
        exec.run("tmux new-session -d -s " + shq(n) + " 2>/dev/null", function () {
            root.refresh();
        });
    }

    function killSession(name) {
        exec.run("tmux kill-session -t " + shq(name) + " 2>/dev/null", function () {
            root.refresh();
        });
    }

    // answer a waiting agent in place (e.g. y/n + Enter) without attaching
    function sendKeys(name, keys, enter) {
        var cmd = "tmux send-keys -t " + shq(name);
        if (keys && keys.length)
            cmd += " " + shq(keys);
        if (enter)
            cmd += " Enter";
        exec.run(cmd + " 2>/dev/null", function () {
            root.refresh();
        });
    }

    function openConfig() {
        var a = Plasmoid.internalAction("configure");
        if (a)
            a.trigger();
    }


    function sanitize(s) {
        return (s || "").trim().replace(/[^A-Za-z0-9_.-]/g, "-").replace(/^[.-]+/, "");
    }
    function shq(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }
    function ago(ts) {
        if (!ts)
            return "";
        return elapsedSec(Math.floor(Date.now() / 1000) - ts);
    }
    // compact duration from an epoch-ms instant, recomputed each tick
    function elapsed(sinceMs) {
        if (!sinceMs)
            return "";
        return elapsedSec(Math.floor((Date.now() - sinceMs) / 1000));
    }
    function elapsedSec(s) {
        s = Math.max(0, s);
        if (s < 60)
            return i18nd(i18nDomain, "just now");
        var m = Math.floor(s / 60);
        if (m < 60)
            return i18nd(i18nDomain, "%1 min", m);
        var h = Math.floor(m / 60);
        if (h < 24)
            return i18nd(i18nDomain, "%1 h", h);
        return i18nd(i18nDomain, "%1 d", Math.floor(h / 24));
    }

    Timer {
        interval: root.refreshSec * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: scanTerminals()

    // drives the Braille spinner on working cards; idle when nobody is working
    Timer {
        interval: 90
        running: root.workingCount > 0
        repeat: true
        onTriggered: root.spinnerFrame = (root.spinnerFrame + 1) % root.spinnerFrames.length
    }

    // nudges elapsed-time labels so "waiting 12 min" advances between polls
    Timer {
        interval: 15000
        running: root.agentCount > 0
        repeat: true
        onTriggered: root.nowTick = (root.nowTick + 1) % 100000
    }
}
