// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    readonly property string i18nDomain: "plasma_applet_org.tsy.tmuxpad"

    property alias cfg_terminalCommand: termField.text
    property alias cfg_refreshInterval: refreshSpin.value
    property alias cfg_previewLines: previewSpin.value
    property alias cfg_notifyOnWaiting: notifyWaitingCheck.checked
    property alias cfg_notifyOnDone: notifyDoneCheck.checked

    QQC2.TextField {
        id: termField
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Attach command:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 24
    }
    QQC2.Label {
        text: i18nd(page.i18nDomain, "%1 is replaced with the session name. Examples:")
        opacity: 0.7
        font: Kirigami.Theme.smallFont
    }
    QQC2.Label {
        text: "konsole -e tmux attach -t %1\n" +
              "wezterm start -- tmux attach -t %1\n" +
              "ghostty -e tmux attach -t %1\n" +
              "alacritty -e tmux attach -t %1"
        opacity: 0.7
        font.family: "monospace"
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    QQC2.SpinBox {
        id: refreshSpin
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Refresh every, sec:")
        from: 1
        to: 60
    }
    QQC2.SpinBox {
        id: previewSpin
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Preview lines:")
        from: 4
        to: 40
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18nd(page.i18nDomain, "Notifications")
    }

    QQC2.CheckBox {
        id: notifyWaitingCheck
        text: i18nd(page.i18nDomain, "When an agent needs input")
    }
    QQC2.CheckBox {
        id: notifyDoneCheck
        text: i18nd(page.i18nDomain, "When an agent finishes working")
    }
    QQC2.Label {
        text: i18nd(page.i18nDomain, "Only detached sessions notify — if you are attached, you already see it.")
        opacity: 0.7
        font: Kirigami.Theme.smallFont
    }
}
