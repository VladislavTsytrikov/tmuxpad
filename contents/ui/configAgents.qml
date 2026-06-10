// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    property alias cfg_agentCommands: agentsArea.text
    property alias cfg_workingPatterns: workingArea.text
    property alias cfg_waitingPatterns: waitingArea.text

    QQC2.Label {
        Layout.fillWidth: true
        text: i18nd(page.i18nDomain,
            "Sessions whose foreground process matches one of these names are treated as AI agents and get a status: working, waiting for input, or idle.")
        wrapMode: Text.WordWrap
        opacity: 0.8
    }

    QQC2.TextArea {
        id: agentsArea
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Agent process names:")
        Kirigami.FormData.labelAlignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 6
        font.family: "monospace"
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Status detection (one regex per line)")
    }

    QQC2.TextArea {
        id: waitingArea
        Kirigami.FormData.label: i18nd(page.i18nDomain, "“Waiting for input” patterns:")
        Kirigami.FormData.labelAlignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 7
        font.family: "monospace"
    }

    QQC2.TextArea {
        id: workingArea
        Kirigami.FormData.label: i18nd(page.i18nDomain, "“Working” patterns:")
        Kirigami.FormData.labelAlignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 5
        font.family: "monospace"
    }

    QQC2.Label {
        Layout.fillWidth: true
        text: i18nd(page.i18nDomain,
            "Patterns are matched against the last visible lines of each session. A Braille spinner (⠋⠙⠹…) at the start of the pane title also counts as “working” — Claude Code sets it automatically.")
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
    }
}
