// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: page

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    property alias cfg_agentCommands: agentsArea.text
    property alias cfg_workingPatterns: workingArea.text
    property alias cfg_waitingPatterns: waitingArea.text

    implicitWidth: Kirigami.Units.gridUnit * 26
    implicitHeight: Kirigami.Units.gridUnit * 34

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: page.width
            spacing: Kirigami.Units.largeSpacing

            // ── Agent processes ──
            SettingsCard {
                title: i18nd(page.i18nDomain, "Agent processes")
                iconName: "applications-development"
                accent: Kirigami.Theme.highlightColor

                PC3.Label {
                    Layout.fillWidth: true
                    text: i18nd(page.i18nDomain,
                        "Sessions whose foreground process matches one of these names are treated as AI agents.")
                    wrapMode: Text.WordWrap
                    opacity: 0.7
                    font: Kirigami.Theme.smallFont
                }
                StyledTextArea {
                    id: agentsArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 6
                }
            }

            // ── Status detection ──
            SettingsCard {
                title: i18nd(page.i18nDomain, "Status detection")
                iconName: "view-filter"
                accent: Kirigami.Theme.neutralTextColor

                PC3.Label {
                    Layout.fillWidth: true
                    text: i18nd(page.i18nDomain, "One regex per line, matched against the last visible lines of each session.")
                    wrapMode: Text.WordWrap
                    opacity: 0.7
                    font: Kirigami.Theme.smallFont
                }

                PC3.Label {
                    text: "⏳  " + i18nd(page.i18nDomain, "“Waiting for input” patterns")
                    font.weight: Font.DemiBold
                    Layout.topMargin: Kirigami.Units.smallSpacing / 2
                }
                StyledTextArea {
                    id: waitingArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 7
                }

                PC3.Label {
                    text: "⚡  " + i18nd(page.i18nDomain, "“Working” patterns")
                    font.weight: Font.DemiBold
                    Layout.topMargin: Kirigami.Units.smallSpacing
                }
                StyledTextArea {
                    id: workingArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 5
                }

                PC3.Label {
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.smallSpacing / 2
                    text: i18nd(page.i18nDomain,
                        "A Braille spinner (⠋⠙⠹…) at the start of the pane title also counts as “working” — Claude Code sets it automatically.")
                    wrapMode: Text.WordWrap
                    opacity: 0.6
                    font: Kirigami.Theme.smallFont
                }
            }

            Item { Layout.fillHeight: true; Layout.minimumHeight: Kirigami.Units.smallSpacing }
        }
    }
}
