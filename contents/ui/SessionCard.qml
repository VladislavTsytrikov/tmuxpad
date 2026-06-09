/*
 * One session as a Mission-Control card: status accent, avatar, live status
 * line with elapsed time, glanceable last-output line, working spinner,
 * waiting glow, hover lift, and hover actions (attach / kill / preview).
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: card

    required property var modelData
    required property var plasmoidItem
    readonly property string i18nDomain: plasmoidItem.i18nDomain
    readonly property string status: modelData.status

    property bool confirming: false
    property bool previewOpen: false

    implicitHeight: bg.implicitHeight

    readonly property color accent: status === "waiting" ? Kirigami.Theme.neutralTextColor
        : status === "working" ? Kirigami.Theme.positiveTextColor
        : Kirigami.Theme.disabledTextColor

    // last non-empty output line, for the glanceable peek
    readonly property string lastLine: {
        var c = (modelData.content || "").split("\n");
        for (var i = c.length - 1; i >= 0; i--)
            if (c[i].trim().length)
                return c[i].trim();
        return "";
    }

    function statusLine() {
        var t = plasmoidItem.elapsed(modelData.since);
        if (status === "waiting")
            return i18nd(i18nDomain, "needs your answer") + (t ? " · " + t : "");
        if (status === "working")
            return i18nd(i18nDomain, "working") + (t ? " · " + t : "");
        if (status === "idle")
            return i18nd(i18nDomain, "idle") + (t ? " · " + t : "");
        return i18ndp(i18nDomain, "%1 window", "%1 windows", modelData.windows)
            + " · " + plasmoidItem.ago(modelData.created);
    }

    // entrance animation
    opacity: 0
    scale: 0.96
    Component.onCompleted: appear.start()
    ParallelAnimation {
        id: appear
        NumberAnimation { target: card; property: "opacity"; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "scale"; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.OutBack }
    }

    Kirigami.ShadowedRectangle {
        id: bg
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        implicitHeight: contentCol.implicitHeight + Kirigami.Units.smallSpacing * 2
        radius: Kirigami.Units.cornerRadius
        color: hover.hovered ? Kirigami.Theme.alternateBackgroundColor : Kirigami.Theme.backgroundColor
        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }

        border.width: card.status === "waiting" ? 1 : 0
        border.color: Qt.alpha(card.accent, glowPulse.value)

        shadow.size: hover.hovered ? Kirigami.Units.gridUnit * 0.8 : Kirigami.Units.smallSpacing * 1.5
        shadow.yOffset: 2
        shadow.color: card.status === "waiting"
            ? Qt.alpha(Kirigami.Theme.neutralTextColor, 0.35 * glowPulse.value)
            : Qt.alpha(Kirigami.Theme.textColor, 0.18)
        Behavior on shadow.size { NumberAnimation { duration: Kirigami.Units.shortDuration } }

        scale: hover.hovered ? 1.02 : 1.0
        Behavior on scale { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic } }

        // pulsing value (1 <-> 0.35) used by waiting glow + accent
        QtObject {
            id: glowPulse
            property real value: 1.0
        }
        SequentialAnimation {
            running: card.status === "waiting"
            loops: Animation.Infinite
            alwaysRunToEnd: true
            NumberAnimation { target: glowPulse; property: "value"; from: 1.0; to: 0.4; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { target: glowPulse; property: "value"; from: 0.4; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
        }

        HoverHandler { id: hover }
        TapHandler {
            enabled: !card.confirming
            onTapped: card.plasmoidItem.attachSession(card.modelData.name)
        }

        // left status accent stripe
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: 4
            radius: 2
            color: card.accent
            opacity: card.status === "waiting" ? glowPulse.value : (card.status === "none" ? 0.4 : 0.9)
        }

        ColumnLayout {
            id: contentCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Kirigami.Units.smallSpacing * 2.5
                rightMargin: Kirigami.Units.smallSpacing
                topMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.smallSpacing / 2

            // ── top row: avatar · name+status · actions ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                AgentAvatar {
                    name: card.modelData.name
                    diameter: Kirigami.Units.gridUnit * 1.9
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing / 2

                        PC3.Label {
                            text: card.modelData.name
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        // working spinner
                        PC3.Label {
                            visible: card.status === "working"
                            text: card.plasmoidItem.spinnerGlyph
                            color: Kirigami.Theme.positiveTextColor
                            font.family: "monospace"
                        }
                        Kirigami.Icon {
                            visible: card.modelData.attached
                            source: "view-visible-symbolic"
                            color: Kirigami.Theme.disabledTextColor
                            isMask: true
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                        }
                        // tool chip
                        Rectangle {
                            visible: card.status !== "none"
                            radius: height / 2
                            color: Qt.alpha(card.accent, 0.16)
                            implicitWidth: toolLabel.implicitWidth + Kirigami.Units.smallSpacing * 1.5
                            implicitHeight: toolLabel.implicitHeight + 2
                            PC3.Label {
                                id: toolLabel
                                anchors.centerIn: parent
                                text: card.modelData.tool
                                color: card.accent
                                font: Kirigami.Theme.smallFont
                            }
                        }
                    }

                    PC3.Label {
                        visible: !card.confirming
                        text: card.statusLine()
                        color: card.status === "waiting" ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.textColor
                        opacity: card.status === "waiting" ? 0.95 : 0.6
                        font: Kirigami.Theme.smallFont
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    PC3.Label {
                        visible: card.confirming
                        text: i18nd(card.i18nDomain, "Kill this session?")
                        color: Kirigami.Theme.negativeTextColor
                        opacity: 0.85
                        font: Kirigami.Theme.smallFont
                        Layout.fillWidth: true
                    }
                }

                // ── actions (hover) ──
                PC3.ToolButton {
                    visible: (hover.hovered || card.previewOpen) && !card.confirming
                    icon.name: card.previewOpen ? "arrow-up" : "arrow-down"
                    display: QQC2.AbstractButton.IconOnly
                    QQC2.ToolTip.text: i18nd(card.i18nDomain, "Preview output")
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: 600
                    onClicked: card.previewOpen = !card.previewOpen
                }
                PC3.ToolButton {
                    visible: hover.hovered && !card.confirming
                    icon.name: "media-playback-start"
                    display: QQC2.AbstractButton.IconOnly
                    QQC2.ToolTip.text: i18nd(card.i18nDomain, "Attach")
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: 600
                    onClicked: card.plasmoidItem.attachSession(card.modelData.name)
                }
                PC3.ToolButton {
                    visible: hover.hovered && !card.confirming
                    icon.name: "window-close"
                    display: QQC2.AbstractButton.IconOnly
                    QQC2.ToolTip.text: i18nd(card.i18nDomain, "Kill")
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: 600
                    onClicked: card.confirming = true
                }
                PC3.ToolButton {
                    visible: card.confirming
                    icon.name: "checkmark"
                    display: QQC2.AbstractButton.IconOnly
                    onClicked: {
                        card.plasmoidItem.killSession(card.modelData.name);
                        card.confirming = false;
                    }
                }
                PC3.ToolButton {
                    visible: card.confirming
                    icon.name: "dialog-cancel"
                    display: QQC2.AbstractButton.IconOnly
                    onClicked: card.confirming = false
                }
            }

            // ── glanceable peek: last output line for waiting/working ──
            PC3.Label {
                visible: !card.previewOpen && !card.confirming
                    && (card.status === "waiting" || card.status === "working")
                    && card.lastLine.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit * 1.9 + Kirigami.Units.smallSpacing
                text: "› " + card.lastLine
                color: Kirigami.Theme.textColor
                opacity: 0.5
                font.family: "monospace"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            // ── full preview (chevron) ──
            Rectangle {
                visible: card.previewOpen
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing / 2
                implicitHeight: previewText.implicitHeight + Kirigami.Units.smallSpacing * 2
                radius: Kirigami.Units.cornerRadius
                color: Kirigami.Theme.alternateBackgroundColor

                Text {
                    id: previewText
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    text: card.previewOpen
                        ? (card.modelData.content || i18nd(card.i18nDomain, "(empty)"))
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
