/*
 * Mission Control: sessions grouped into status buckets (needs-you / working /
 * idle / terminals), each a card. Header shows live summary chips.
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

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28

    // bucket index -> {emoji, title}
    readonly property var buckets: [
        { emoji: "⏳", title: i18nd(i18nDomain, "Needs you") },
        { emoji: "⚡", title: i18nd(i18nDomain, "Working") },
        { emoji: "💤", title: i18nd(i18nDomain, "Idle") },
        { emoji: "🖥", title: i18nd(i18nDomain, "Terminals") }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

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

            // summary chips
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
        QQC2.ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ColumnLayout {
                // fit inside the viewport (minus the vertical scrollbar)
                width: scroll.availableWidth
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: 4
                    delegate: ColumnLayout {
                        id: section
                        required property int index
                        readonly property var rows: full.plasmoidItem.sessionsIn(index)
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing / 2
                        visible: rows.length > 0

                        // section header
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Kirigami.Units.smallSpacing / 2
                            spacing: Kirigami.Units.smallSpacing / 2
                            PC3.Label {
                                text: full.buckets[section.index].emoji + "  "
                                    + full.buckets[section.index].title
                                font.weight: Font.Bold
                                opacity: 0.85
                            }
                            PC3.Label {
                                text: "· " + section.rows.length
                                opacity: 0.45
                                font: Kirigami.Theme.smallFont
                            }
                            Item { Layout.fillWidth: true }
                        }

                        Repeater {
                            model: section.rows
                            delegate: SessionCard {
                                Layout.fillWidth: true
                                plasmoidItem: full.plasmoidItem
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
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
