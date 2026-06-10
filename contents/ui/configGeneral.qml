// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import "terminals.js" as Terminals

Kirigami.FormLayout {
    id: page

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    property string cfg_terminalId
    property alias cfg_terminalCommand: termField.text
    property alias cfg_refreshInterval: refreshSpin.value
    property alias cfg_previewLines: previewSpin.value
    property alias cfg_notifyOnWaiting: notifyWaitingCheck.checked
    property alias cfg_notifyOnDone: notifyDoneCheck.checked

    // installed terminal ids, filled by the scan below
    property var installed: []

    // model for the combo: Auto + each installed terminal + Custom
    function buildModel() {
        var auto = Terminals.label(installed.length ? installed[0] : "");
        var rows = [{
            "id": "auto",
            "label": installed.length
                ? i18nd(i18nDomain, "Automatic (%1)", auto)
                : i18nd(i18nDomain, "Automatic")
        }];
        for (var i = 0; i < installed.length; i++)
            rows.push({ "id": installed[i], "label": Terminals.label(installed[i]) });
        rows.push({ "id": "custom", "label": i18nd(i18nDomain, "Custom command…") });
        return rows;
    }

    function syncCombo() {
        termCombo.model = buildModel();
        var idx = 0;
        for (var i = 0; i < termCombo.model.length; i++)
            if (termCombo.model[i].id === cfg_terminalId) { idx = i; break; }
        termCombo.currentIndex = idx;
    }

    P5Support.DataSource {
        id: scanner
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            var out = (data["stdout"] || "");
            page.installed = out.split("\n").map(l => l.trim()).filter(l => l.length > 0);
            disconnectSource(source);
            page.syncCombo();
        }
    }

    Component.onCompleted: {
        var cmd = "for t in " + Terminals.ids().join(" ")
            + "; do command -v \"$t\" >/dev/null 2>&1 && printf '%s\\n' \"$t\"; done";
        scanner.connectSource(cmd);
    }

    QQC2.ComboBox {
        id: termCombo
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Open tmux in:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        textRole: "label"
        valueRole: "id"
        model: page.buildModel()
        onActivated: page.cfg_terminalId = currentValue
        Component.onCompleted: page.syncCombo()
    }
    QQC2.Label {
        text: termCombo.count <= 2
            ? i18nd(page.i18nDomain, "No known terminal found — pick “Custom command…” and enter your own.")
            : i18nd(page.i18nDomain, "Detected terminals are listed automatically. “Automatic” uses the first one.")
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        font: Kirigami.Theme.smallFont
    }

    // ── custom command (only when "Custom" is selected) ──
    QQC2.TextField {
        id: termField
        visible: page.cfg_terminalId === "custom"
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Custom command:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 24
        placeholderText: "konsole -e tmux attach -t %1"
    }
    QQC2.Label {
        visible: page.cfg_terminalId === "custom"
        text: i18nd(page.i18nDomain, "%1 is replaced with the session name.")
        opacity: 0.7
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    QQC2.SpinBox {
        id: refreshSpin
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Refresh every, sec:")
        from: 1
        to: 60
    }
    QQC2.SpinBox {
        id: previewSpin
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Preview lines:")
        from: 4
        to: 40
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Notifications")
    }

    QQC2.CheckBox {
        id: notifyWaitingCheck
        text: i18nd(page.i18nDomain, "When an agent needs input")
    }
    QQC2.CheckBox {
        id: notifyDoneCheck
        text: i18nd(page.i18nDomain, "When an agent finishes working")
    }
    QQC2.Label {
        text: i18nd(page.i18nDomain, "Only detached sessions notify — if you are attached, you already see it.")
        opacity: 0.7
        font: Kirigami.Theme.smallFont
    }
}
