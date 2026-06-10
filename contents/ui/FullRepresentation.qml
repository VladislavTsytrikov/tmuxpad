// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * Mission Control: sessions grouped into status buckets (needs-you / working /
 * idle / terminals) via a stable ListModel, each a card. Header shows live
 * summary chips. Section headers and add/remove/move animations come from the
 * ListView itself, so updates never recreate cards.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

Item {
    id: full

    required property var plasmoidItem
    readonly property string i18nDomain: plasmoidItem.i18nDomain

    // toggles the in-widget settings panel (slides over the session list)
    property bool configuring: false

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    Layout.preferredWidth: Kirigami.Units.gridUnit * 24
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28

    readonly property var bucketMeta: [
        { emoji: "⏳", title: i18nd(i18nDomain, "Needs you") },
        { emoji: "⚡", title: i18nd(i18nDomain, "Working") },
        { emoji: "💤", title: i18nd(i18nDomain, "Idle") },
        { emoji: "🖥", title: i18nd(i18nDomain, "Terminals") }
    ]
    function bucketCount(b) {
        return b === 0 ? plasmoidItem.waitingCount
            : b === 1 ? plasmoidItem.workingCount
            : b === 2 ? plasmoidItem.idleCount
            : plasmoidItem.sessions.length - plasmoidItem.agentCount;
    }

    // ── in-widget settings (slides in from the right) ──
    SettingsPanel {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        plasmoidItem: full.plasmoidItem
        opacity: full.configuring ? 1 : 0
        visible: opacity > 0
        x: full.configuring ? 0 : Kirigami.Units.gridUnit
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }
        Behavior on x { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
        onClosed: full.configuring = false
    }

    ColumnLayout {
        id: mainView
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        opacity: full.configuring ? 0 : 1
        visible: opacity > 0
        x: full.configuring ? -Kirigami.Units.gridUnit : 0
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }
        Behavior on x { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }

        // ── header ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "utilities-terminal-symbolic"
                isMask: true
                color: Kirigami.Theme.textColor
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            }
            PlasmaExtras.Heading {
                text: "tmux"
                level: 3
                Layout.fillWidth: true
            }

            Row {
                spacing: Kirigami.Units.smallSpacing
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    visible: full.plasmoidItem.waitingCount > 0
                    radius: height / 2
                    color: Qt.alpha(Kirigami.Theme.neutralTextColor, 0.18)
                    width: wc.implicitWidth + Kirigami.Units.smallSpacing * 2
                    height: wc.implicitHeight + 3
                    PC3.Label {
                        id: wc
                        anchors.centerIn: parent
                        text: "⏳ " + full.plasmoidItem.waitingCount
                        color: Kirigami.Theme.neutralTextColor
                        font: Kirigami.Theme.smallFont
                    }
                }
                Rectangle {
                    visible: full.plasmoidItem.workingCount > 0
                    radius: height / 2
                    color: Qt.alpha(Kirigami.Theme.positiveTextColor, 0.18)
                    width: rc.implicitWidth + Kirigami.Units.smallSpacing * 2
                    height: rc.implicitHeight + 3
                    PC3.Label {
                        id: rc
                        anchors.centerIn: parent
                        text: "⚡ " + full.plasmoidItem.workingCount
                        color: Kirigami.Theme.positiveTextColor
                        font: Kirigami.Theme.smallFont
                    }
                }
                PC3.Label {
                    visible: full.plasmoidItem.serverUp && full.plasmoidItem.sessions.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: "· " + full.plasmoidItem.sessions.length
                    opacity: 0.5
                }
            }

            PC3.ToolButton {
                icon.name: "configure"
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: i18nd(full.i18nDomain, "Settings")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: 600
                onClicked: full.configuring = true
            }
            PC3.ToolButton {
                icon.name: "view-refresh"
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: i18nd(full.i18nDomain, "Refresh")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: 600
                onClicked: full.plasmoidItem.refresh()
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            opacity: 0.5
        }

        // ── grouped cards ──
        ListView {
            id: lv
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: full.plasmoidItem.sessionsModel
            spacing: Kirigami.Units.smallSpacing
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

            section.property: "bucket"
            section.criteria: ViewSection.FullString
            section.delegate: RowLayout {
                required property string section
                width: ListView.view.width
                spacing: Kirigami.Units.smallSpacing / 2
                PC3.Label {
                    text: full.bucketMeta[parseInt(section)].emoji + "  "
                        + full.bucketMeta[parseInt(section)].title
                    font.weight: Font.Bold
                    opacity: 0.85
                }
                PC3.Label {
                    text: "· " + full.bucketCount(parseInt(section))
                    opacity: 0.45
                    font: Kirigami.Theme.smallFont
                }
                Item { Layout.fillWidth: true }
            }

            delegate: SessionCard {
                width: lv.width
                plasmoidItem: full.plasmoidItem
            }

            add: Transition {
                NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Kirigami.Units.longDuration }
                NumberAnimation { properties: "scale"; from: 0.94; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.OutBack }
            }
            remove: Transition {
                NumberAnimation { properties: "opacity"; to: 0; duration: Kirigami.Units.shortDuration }
                NumberAnimation { properties: "scale"; to: 0.94; duration: Kirigami.Units.shortDuration }
            }
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
            }
            move: Transition {
                NumberAnimation { properties: "x,y"; duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
            }
        }

        // ── empty / no-server placeholder ──
        PlasmaExtras.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: full.plasmoidItem.sessions.length === 0 && !full.plasmoidItem.firstLoad
            iconName: full.plasmoidItem.serverUp ? "dialog-information" : "system-run"
            text: full.plasmoidItem.serverUp
                ? i18nd(full.i18nDomain, "No active sessions")
                : i18nd(full.i18nDomain, "tmux server is not running")
            explanation: full.plasmoidItem.serverUp
                ? i18nd(full.i18nDomain, "Create your first one below")
                : i18nd(full.i18nDomain, "Creating a session will start it")
        }

        // ── new session bar ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PC3.TextField {
                id: newName
                Layout.fillWidth: true
                placeholderText: i18nd(full.i18nDomain, "new session name…")
                onAccepted: {
                    full.plasmoidItem.newSession(text);
                    text = "";
                }
            }
            PC3.Button {
                icon.name: "list-add"
                text: i18nd(full.i18nDomain, "Create")
                enabled: newName.text.trim().length > 0
                onClicked: {
                    full.plasmoidItem.newSession(newName.text);
                    newName.text = "";
                }
            }
        }
    }
}
