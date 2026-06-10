// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * A settings section as a Mission-Control style card: icon + title header,
 * separator, then the content placed inside it. Matches the widget's look.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Kirigami.ShadowedRectangle {
    id: card

    property string title: ""
    property string iconName: ""
    property color accent: Kirigami.Theme.highlightColor
    default property alias cardContent: contentColumn.data

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2

    radius: Kirigami.Units.gridUnit * 0.6
    color: Kirigami.Theme.backgroundColor
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // floating card: no hard border, soft elevated shadow
    border.width: 0
    shadow.size: Kirigami.Units.gridUnit
    shadow.yOffset: 3
    shadow.color: Qt.alpha(Kirigami.Theme.textColor, 0.16)

    // subtle top sheen for depth
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.alpha(Kirigami.Theme.textColor, 0.025) }
            GradientStop { position: 0.35; color: "transparent" }
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        // header: tinted icon chip + title
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                radius: Kirigami.Units.cornerRadius
                color: Qt.alpha(card.accent, 0.15)
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: card.iconName
                    color: card.accent
                    isMask: true
                }
            }
            PC3.Label {
                text: card.title
                font.weight: Font.Bold
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
                Layout.fillWidth: true
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            opacity: 0.25
        }

        // content slot
        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing / 2
            spacing: Kirigami.Units.smallSpacing
        }
    }
}
