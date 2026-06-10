// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * A monospace text area with a rounded, focus-aware background — a more modern
 * look than the default flat field.
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.TextArea {
    id: area
    font.family: "monospace"
    wrapMode: TextEdit.NoWrap
    padding: Kirigami.Units.smallSpacing * 1.5
    selectByMouse: true

    background: Rectangle {
        radius: Kirigami.Units.cornerRadius
        color: Qt.alpha(Kirigami.Theme.textColor, area.activeFocus ? 0.03 : 0.05)
        border.width: 1
        border.color: area.activeFocus
            ? Kirigami.Theme.focusColor
            : Qt.alpha(Kirigami.Theme.textColor, 0.12)
        Behavior on border.color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
    }
}
