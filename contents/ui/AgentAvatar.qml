/*
 * A small circular avatar with the session's initial, tinted by a colour
 * derived deterministically from the name. Self-contained — no kirigami-addons
 * dependency, so it works on any Plasma 6 install.
 */
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: avatar

    property string name: ""
    property real diameter: Kirigami.Units.gridUnit * 1.8

    implicitWidth: diameter
    implicitHeight: diameter

    // stable hash -> hue, so the same session always gets the same colour
    function hueFor(s) {
        var h = 0;
        for (var i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) % 360;
        return h / 360;
    }
    readonly property color tint: Qt.hsla(hueFor(name), 0.55, 0.55, 1.0)

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: avatar.tint
        antialiasing: true

        // subtle top highlight for a little depth
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }

        Text {
            anchors.centerIn: parent
            text: avatar.name.length ? avatar.name.charAt(0).toUpperCase() : "?"
            color: "white"
            font.pixelSize: parent.height * 0.5
            font.weight: Font.Bold
        }
    }
}
