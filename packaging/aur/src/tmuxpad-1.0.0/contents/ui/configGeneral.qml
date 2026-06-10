// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import "terminals.js" as Terminals

Item {
    id: page

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    property string cfg_terminalId
    property alias cfg_terminalCommand: termField.text
    property alias cfg_refreshInterval: refreshSpin.value
    property alias cfg_previewLines: previewSpin.value
    property alias cfg_notifyOnWaiting: notifyWaitingCheck.checked
    property alias cfg_notifyOnDone: notifyDoneCheck.checked

    implicitWidth: Kirigami.Units.gridUnit * 26
    implicitHeight: Kirigami.Units.gridUnit * 32

    property var installed: []

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
    function previewCmd() {
        var id = cfg_terminalId;
        if (id === "custom")
            return cfg_terminalCommand;
        if (id === "auto")
            return installed.length ? Terminals.template(installed[0]) : "—";
        return Terminals.template(id);
    }

    P5Support.DataSource {
        id: scanner
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            page.installed = (data["stdout"] || "").split("\n").map(l => l.trim()).filter(l => l.length > 0);
            disconnectSource(source);
            page.syncCombo();
        }
    }
    Component.onCompleted: {
        var cmd = "for t in " + Terminals.ids().join(" ")
            + "; do command -v \"$t\" >/dev/null 2>&1 && printf '%s\\n' \"$t\"; done";
        scanner.connectSource(cmd);
    }

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: page.width
            spacing: Kirigami.Units.largeSpacing

            // ── Terminal ──
            SettingsCard {
                title: i18nd(page.i18nDomain, "Terminal")
                iconName: "utilities-terminal"
                accent: Kirigami.Theme.highlightColor

                GridLayout {
                    columns: 2
                    columnSpacing: Kirigami.Units.smallSpacing
                    rowSpacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    PC3.Label { text: i18nd(page.i18nDomain, "Open tmux in:") }
                    QQC2.ComboBox {
                        id: termCombo
                        Layout.fillWidth: true
                        textRole: "label"
                        valueRole: "id"
                        model: page.buildModel()
                        onActivated: page.cfg_terminalId = currentValue
                        Component.onCompleted: page.syncCombo()
                    }
                }

                // live command preview
                Rectangle {
                    Layout.fillWidth: true
                    visible: page.cfg_terminalId !== "custom"
                    implicitHeight: cmdPreview.implicitHeight + Kirigami.Units.smallSpacing * 2
                    radius: Kirigami.Units.cornerRadius
                    color: Kirigami.Theme.alternateBackgroundColor
                    PC3.Label {
                        id: cmdPreview
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        text: "› " + page.previewCmd()
                        font.family: "monospace"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.7
                        elide: Text.ElideRight
                    }
                }

                QQC2.TextField {
                    id: termField
                    visible: page.cfg_terminalId === "custom"
                    Layout.fillWidth: true
                    placeholderText: "konsole -e tmux attach -t %1"
                    padding: Kirigami.Units.smallSpacing * 1.5
                    background: Rectangle {
                        radius: Kirigami.Units.cornerRadius
                        color: Qt.alpha(Kirigami.Theme.textColor, termField.activeFocus ? 0.03 : 0.05)
                        border.width: 1
                        border.color: termField.activeFocus
                            ? Kirigami.Theme.focusColor
                            : Qt.alpha(Kirigami.Theme.textColor, 0.12)
                        Behavior on border.color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
                    }
                }
                PC3.Label {
                    visible: page.cfg_terminalId === "custom"
                    text: i18nd(page.i18nDomain, "%1 is replaced with the session name.")
                    opacity: 0.6
                    font: Kirigami.Theme.smallFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                PC3.Label {
                    visible: page.cfg_terminalId !== "custom"
                    text: termCombo.count <= 2
                        ? i18nd(page.i18nDomain, "No known terminal found — pick “Custom command…” and enter your own.")
                        : i18nd(page.i18nDomain, "Detected terminals are listed automatically. “Automatic” uses the first one.")
                    opacity: 0.6
                    font: Kirigami.Theme.smallFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            // ── Refresh ──
            SettingsCard {
                title: i18nd(page.i18nDomain, "Updates")
                iconName: "view-refresh"
                accent: Kirigami.Theme.positiveTextColor

                GridLayout {
                    columns: 2
                    columnSpacing: Kirigami.Units.largeSpacing
                    rowSpacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    PC3.Label { text: i18nd(page.i18nDomain, "Refresh every, sec:") }
                    QQC2.SpinBox { id: refreshSpin; from: 1; to: 60 }
                    PC3.Label { text: i18nd(page.i18nDomain, "Preview lines:") }
                    QQC2.SpinBox { id: previewSpin; from: 4; to: 40 }
                }
            }

            // ── Notifications ──
            SettingsCard {
                title: i18nd(page.i18nDomain, "Notifications")
                iconName: "preferences-desktop-notification"
                accent: Kirigami.Theme.neutralTextColor

                QQC2.CheckBox {
                    id: notifyWaitingCheck
                    text: i18nd(page.i18nDomain, "When an agent needs input")
                }
                QQC2.CheckBox {
                    id: notifyDoneCheck
                    text: i18nd(page.i18nDomain, "When an agent finishes working")
                }
                PC3.Label {
                    text: i18nd(page.i18nDomain, "Only detached sessions notify — if you are attached, you already see it.")
                    opacity: 0.6
                    font: Kirigami.Theme.smallFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            Item { Layout.fillHeight: true; Layout.minimumHeight: Kirigami.Units.smallSpacing }
        }
    }
}
