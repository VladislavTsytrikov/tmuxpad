/*
 * Session list: status dot per agent, expandable output preview,
 * attach on click, inline kill confirmation, new-session bar.
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

    Layout.minimumWidth: Kirigami.Units.gridUnit * 14
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Kirigami.Units.gridUnit * 22

    function statusColor(status) {
        switch (status) {
        case "waiting":
            return Kirigami.Theme.neutralTextColor;
        case "working":
            return Kirigami.Theme.positiveTextColor;
        default:
            return Kirigami.Theme.disabledTextColor;
        }
    }

    function metaText(m) {
        var parts = [];
        if (m.status === "waiting")
            parts.push(m.tool + " · " + i18nd(i18nDomain, "needs your input"));
        else if (m.status === "working")
            parts.push(m.tool + " · " + i18nd(i18nDomain, "working…"));
        else if (m.status === "idle")
            parts.push(m.tool + " · " + i18nd(i18nDomain, "idle"));
        else
            parts.push(i18ndp(i18nDomain, "%1 window", "%1 windows", m.windows));
        var age = plasmoidItem.ago(m.created);
        if (age)
            parts.push(age);
        return parts.join(" · ");
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        // ── header ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "utilities-terminal"
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            }
            PlasmaExtras.Heading {
                text: "tmux"
                level: 3
                Layout.fillWidth: true
            }
            PC3.Label {
                visible: full.plasmoidItem.waitingCount > 0
                text: i18ndp(full.i18nDomain, "%1 waiting", "%1 waiting", full.plasmoidItem.waitingCount)
                color: Kirigami.Theme.neutralTextColor
                font: Kirigami.Theme.smallFont
            }
            PC3.Label {
                visible: full.plasmoidItem.serverUp && full.plasmoidItem.sessions.length > 0
                text: full.plasmoidItem.sessions.length
                opacity: 0.5
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

        // ── list ──
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            ListView {
                id: lv
                model: full.plasmoidItem.sessions
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: del
                    required property var modelData
                    property bool confirming: false
                    property bool previewOpen: false
                    width: lv.width
                    height: mainRow.height + (previewOpen ? preview.height + Kirigami.Units.smallSpacing : 0)

                    Item {
                        id: mainRow
                        width: parent.width
                        height: Kirigami.Units.gridUnit * 2.4

                        Rectangle {
                            anchors.fill: parent
                            radius: Kirigami.Units.cornerRadius || 6
                            color: Kirigami.Theme.highlightColor
                            opacity: hover.hovered ? 0.12 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: 110 }
                            }
                        }

                        HoverHandler {
                            id: hover
                        }
                        TapHandler {
                            enabled: !del.confirming
                            onTapped: full.plasmoidItem.attachSession(del.modelData.name)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                            anchors.rightMargin: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.smallSpacing

                            // status dot: orange pulse = waiting, green = working
                            Rectangle {
                                id: dot
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 9
                                implicitHeight: 9
                                radius: 4.5
                                color: full.statusColor(del.modelData.status)
                                SequentialAnimation on opacity {
                                    running: del.modelData.status === "waiting"
                                    loops: Animation.Infinite
                                    alwaysRunToEnd: true
                                    NumberAnimation { from: 1; to: 0.25; duration: 500 }
                                    NumberAnimation { from: 0.25; to: 1; duration: 500 }
                                }
                            }

                            // name + meta
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing
                                    PC3.Label {
                                        text: del.modelData.name
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Kirigami.Icon {
                                        visible: del.modelData.attached
                                        source: "view-visible"
                                        opacity: 0.55
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    }
                                }
                                PC3.Label {
                                    visible: !del.confirming
                                    text: full.metaText(del.modelData)
                                    color: del.modelData.status === "waiting"
                                        ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor
                                    opacity: del.modelData.status === "waiting" ? 0.9 : 0.55
                                    font: Kirigami.Theme.smallFont
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                PC3.Label {
                                    visible: del.confirming
                                    text: i18nd(full.i18nDomain, "Kill this session?")
                                    opacity: 0.7
                                    color: Kirigami.Theme.negativeTextColor
                                    font: Kirigami.Theme.smallFont
                                    Layout.fillWidth: true
                                }
                            }

                            // normal actions (on hover)
                            PC3.ToolButton {
                                visible: (hover.hovered || del.previewOpen) && !del.confirming
                                icon.name: del.previewOpen ? "arrow-up" : "arrow-down"
                                display: QQC2.AbstractButton.IconOnly
                                QQC2.ToolTip.text: i18nd(full.i18nDomain, "Preview output")
                                QQC2.ToolTip.visible: hovered
                                QQC2.ToolTip.delay: 600
                                onClicked: del.previewOpen = !del.previewOpen
                            }
                            PC3.ToolButton {
                                visible: hover.hovered && !del.confirming
                                icon.name: "media-playback-start"
                                display: QQC2.AbstractButton.IconOnly
                                QQC2.ToolTip.text: i18nd(full.i18nDomain, "Attach")
                                QQC2.ToolTip.visible: hovered
                                QQC2.ToolTip.delay: 600
                                onClicked: full.plasmoidItem.attachSession(del.modelData.name)
                            }
                            PC3.ToolButton {
                                visible: hover.hovered && !del.confirming
                                icon.name: "window-close"
                                display: QQC2.AbstractButton.IconOnly
                                QQC2.ToolTip.text: i18nd(full.i18nDomain, "Kill")
                                QQC2.ToolTip.visible: hovered
                                QQC2.ToolTip.delay: 600
                                onClicked: del.confirming = true
                            }

                            // confirm actions
                            PC3.ToolButton {
                                visible: del.confirming
                                icon.name: "checkmark"
                                display: QQC2.AbstractButton.IconOnly
                                onClicked: {
                                    full.plasmoidItem.killSession(del.modelData.name);
                                    del.confirming = false;
                                }
                            }
                            PC3.ToolButton {
                                visible: del.confirming
                                icon.name: "dialog-cancel"
                                display: QQC2.AbstractButton.IconOnly
                                onClicked: del.confirming = false
                            }
                        }
                    }

                    // ── output preview ──
                    Rectangle {
                        id: preview
                        visible: del.previewOpen
                        anchors.top: mainRow.bottom
                        anchors.topMargin: Kirigami.Units.smallSpacing
                        width: parent.width
                        height: previewText.implicitHeight + Kirigami.Units.smallSpacing * 2
                        radius: Kirigami.Units.cornerRadius || 6
                        color: Kirigami.Theme.alternateBackgroundColor
                        clip: true

                        Text {
                            id: previewText
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            text: del.previewOpen
                                ? (del.modelData.content || i18nd(full.i18nDomain, "(empty)"))
                                : ""
                            color: Kirigami.Theme.textColor
                            font.family: "monospace"
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            textFormat: Text.PlainText
                            wrapMode: Text.NoWrap
                        }
                    }
                }
            }
        }

        // ── empty / no-server placeholder ──
        PlasmaExtras.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: lv.count === 0 && !full.plasmoidItem.firstLoad
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
