// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * In-widget settings panel — fully custom, in the Mission-Control style, with
 * no system config-dialog chrome. Reads and writes Plasmoid.configuration
 * directly (changes apply live).
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "terminals.js" as Terminals

Item {
    id: panel

    required property var plasmoidItem
    readonly property string i18nDomain: plasmoidItem.i18nDomain
    signal closed()

    readonly property var installed: plasmoidItem.availableTerminals

    function buildModel() {
        var auto = Terminals.label(installed.length ? installed[0] : "");
        var rows = [{
            "id": "auto",
            "label": installed.length ? i18nd(i18nDomain, "Automatic (%1)", auto)
                                      : i18nd(i18nDomain, "Automatic")
        }];
        for (var i = 0; i < installed.length; i++)
            rows.push({ "id": installed[i], "label": Terminals.label(installed[i]) });
        rows.push({ "id": "custom", "label": i18nd(i18nDomain, "Custom command…") });
        return rows;
    }
    function previewCmd() {
        var id = Plasmoid.configuration.terminalId;
        if (id === "custom")
            return Plasmoid.configuration.terminalCommand;
        if (id === "auto")
            return installed.length ? Terminals.template(installed[0]) : "—";
        return Terminals.template(id);
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        // ── header: back · title ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PC3.ToolButton {
                icon.name: "draw-arrow-back"
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: i18nd(panel.i18nDomain, "Back")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: 600
                onClicked: panel.closed()
            }
            PlasmaExtras.Heading {
                text: i18nd(panel.i18nDomain, "Settings")
                level: 3
                Layout.fillWidth: true
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            opacity: 0.5
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: panel.width - Kirigami.Units.smallSpacing * 2
                spacing: Kirigami.Units.largeSpacing

                // ── Placement (highlighted feature) ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Put it on your desktop")
                    iconName: "computer"
                    accent: Kirigami.Theme.positiveTextColor

                    PC3.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        opacity: 0.75
                        font: Kirigami.Theme.smallFont
                        text: i18nd(panel.i18nDomain, "Drop TmuxPad on the desktop for a big, always-on mission-control dashboard. In a panel it stays a compact icon with a badge — use both!")
                    }
                    PC3.Button {
                        text: i18nd(panel.i18nDomain, "Add to desktop")
                        icon.name: "list-add"
                        Layout.alignment: Qt.AlignLeft
                        onClicked: {
                            panel.plasmoidItem.addToDesktop();
                            panel.closed();
                        }
                    }
                }

                // ── Appearance ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Appearance")
                    iconName: "preferences-desktop-color"
                    accent: Kirigami.Theme.highlightColor

                    QQC2.Switch {
                        text: i18nd(panel.i18nDomain, "TmuxPad Dark skin")
                        checked: Plasmoid.configuration.uiTheme === "dark"
                        onToggled: Plasmoid.configuration.uiTheme = checked ? "dark" : "system"
                    }
                    PC3.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        opacity: 0.65
                        font: Kirigami.Theme.smallFont
                        text: i18nd(panel.i18nDomain, "A built-in dark theme (Tokyo Night) that looks the same on every machine. Off = follow your Plasma colours.")
                    }
                }

                // ── Terminal ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Terminal")
                    iconName: "utilities-terminal"
                    accent: Kirigami.Theme.highlightColor

                    GridLayout {
                        columns: 2
                        columnSpacing: Kirigami.Units.smallSpacing
                        rowSpacing: Kirigami.Units.smallSpacing
                        Layout.fillWidth: true
                        PC3.Label { text: i18nd(panel.i18nDomain, "Open tmux in:") }
                        QQC2.ComboBox {
                            id: termCombo
                            Layout.fillWidth: true
                            textRole: "label"
                            valueRole: "id"
                            model: panel.buildModel()
                            onActivated: Plasmoid.configuration.terminalId = currentValue
                            function sync() {
                                var idx = 0;
                                for (var i = 0; i < model.length; i++)
                                    if (model[i].id === Plasmoid.configuration.terminalId) { idx = i; break; }
                                currentIndex = idx;
                            }
                            Component.onCompleted: sync()
                            Connections {
                                target: panel
                                function onInstalledChanged() { termCombo.model = panel.buildModel(); termCombo.sync(); }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: Plasmoid.configuration.terminalId !== "custom"
                        implicitHeight: cmdPreview.implicitHeight + Kirigami.Units.smallSpacing * 2
                        radius: Kirigami.Units.cornerRadius
                        color: Qt.alpha(Kirigami.Theme.textColor, 0.05)
                        PC3.Label {
                            id: cmdPreview
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            text: "› " + panel.previewCmd()
                            font.family: "monospace"
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            opacity: 0.7
                            elide: Text.ElideRight
                        }
                    }

                    QQC2.TextField {
                        id: termField
                        visible: Plasmoid.configuration.terminalId === "custom"
                        Layout.fillWidth: true
                        text: Plasmoid.configuration.terminalCommand
                        placeholderText: "konsole -e tmux attach -t %1"
                        padding: Kirigami.Units.smallSpacing * 1.5
                        onTextEdited: Plasmoid.configuration.terminalCommand = text
                        background: Rectangle {
                            radius: Kirigami.Units.cornerRadius
                            color: Qt.alpha(Kirigami.Theme.textColor, termField.activeFocus ? 0.03 : 0.05)
                            border.width: 1
                            border.color: termField.activeFocus ? Kirigami.Theme.focusColor : Qt.alpha(Kirigami.Theme.textColor, 0.12)
                            Behavior on border.color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
                        }
                    }
                    PC3.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        opacity: 0.6
                        font: Kirigami.Theme.smallFont
                        text: Plasmoid.configuration.terminalId === "custom"
                            ? i18nd(panel.i18nDomain, "%1 is replaced with the session name.")
                            : i18nd(panel.i18nDomain, "Detected terminals are listed automatically. “Automatic” uses the first one.")
                    }
                }

                // ── Updates ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Updates")
                    iconName: "view-refresh"
                    accent: Kirigami.Theme.positiveTextColor

                    GridLayout {
                        columns: 2
                        columnSpacing: Kirigami.Units.largeSpacing
                        rowSpacing: Kirigami.Units.smallSpacing
                        Layout.fillWidth: true
                        PC3.Label { text: i18nd(panel.i18nDomain, "Refresh every, sec:") }
                        QQC2.SpinBox {
                            from: 1; to: 60
                            value: Plasmoid.configuration.refreshInterval
                            onValueModified: Plasmoid.configuration.refreshInterval = value
                        }
                        PC3.Label { text: i18nd(panel.i18nDomain, "Preview lines:") }
                        QQC2.SpinBox {
                            from: 4; to: 40
                            value: Plasmoid.configuration.previewLines
                            onValueModified: Plasmoid.configuration.previewLines = value
                        }
                    }
                }

                // ── Notifications ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Notifications")
                    iconName: "preferences-desktop-notification"
                    accent: Kirigami.Theme.neutralTextColor

                    QQC2.CheckBox {
                        text: i18nd(panel.i18nDomain, "When an agent needs input")
                        checked: Plasmoid.configuration.notifyOnWaiting
                        onToggled: Plasmoid.configuration.notifyOnWaiting = checked
                    }
                    QQC2.CheckBox {
                        text: i18nd(panel.i18nDomain, "When an agent finishes working")
                        checked: Plasmoid.configuration.notifyOnDone
                        onToggled: Plasmoid.configuration.notifyOnDone = checked
                    }
                }

                // ── Agents ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Agent processes")
                    iconName: "applications-development"
                    accent: Kirigami.Theme.highlightColor

                    PC3.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        opacity: 0.7
                        font: Kirigami.Theme.smallFont
                        text: i18nd(panel.i18nDomain, "Sessions whose foreground process matches one of these names are treated as AI agents.")
                    }
                    StyledTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 6
                        text: Plasmoid.configuration.agentCommands
                        onTextChanged: Plasmoid.configuration.agentCommands = text
                    }
                }

                // ── Status detection ──
                SettingsCard {
                    title: i18nd(panel.i18nDomain, "Status detection")
                    iconName: "view-filter"
                    accent: Kirigami.Theme.neutralTextColor

                    PC3.Label {
                        text: "⏳  " + i18nd(panel.i18nDomain, "“Waiting for input” patterns")
                        font.weight: Font.DemiBold
                    }
                    StyledTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 6
                        text: Plasmoid.configuration.waitingPatterns
                        onTextChanged: Plasmoid.configuration.waitingPatterns = text
                    }
                    PC3.Label {
                        text: "⚡  " + i18nd(panel.i18nDomain, "“Working” patterns")
                        font.weight: Font.DemiBold
                        Layout.topMargin: Kirigami.Units.smallSpacing
                    }
                    StyledTextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                        text: Plasmoid.configuration.workingPatterns
                        onTextChanged: Plasmoid.configuration.workingPatterns = text
                    }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: Kirigami.Units.smallSpacing }
            }
        }
    }
}
