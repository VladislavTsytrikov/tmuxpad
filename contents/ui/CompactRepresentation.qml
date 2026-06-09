/*
 * Panel icon: terminal symbol with a count badge.
 * Orange badge = agents waiting for input, themed badge = running agents.
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

MouseArea {
    id: compact

    required property var plasmoidItem

    readonly property int waiting: plasmoidItem.waitingCount
    readonly property int agents: plasmoidItem.agentCount

    onClicked: plasmoidItem.expanded = !plasmoidItem.expanded

    Kirigami.Icon {
        anchors.fill: parent
        source: Plasmoid.icon
        active: compact.containsMouse
    }

    Rectangle {
        id: badge
        visible: compact.waiting > 0 || compact.agents > 0
        anchors {
            right: parent.right
            top: parent.top
        }
        width: Math.max(badgeLabel.implicitWidth + 4, height)
        height: badgeLabel.implicitHeight + 2
        radius: height / 2
        color: compact.waiting > 0 ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.highlightColor

        // gently pulse to pull the eye when an agent is waiting
        SequentialAnimation on opacity {
            running: compact.waiting > 0
            loops: Animation.Infinite
            alwaysRunToEnd: true
            NumberAnimation { from: 1.0; to: 0.45; duration: 850; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.45; to: 1.0; duration: 850; easing.type: Easing.InOutSine }
        }

        PC3.Label {
            id: badgeLabel
            anchors.centerIn: parent
            text: compact.waiting > 0 ? compact.waiting : compact.agents
            font: Kirigami.Theme.smallFont
            color: Kirigami.Theme.highlightedTextColor
        }
    }
}
