// SPDX-FileCopyrightText: 2026 Vlad Tsytrikov <vladislavtsytrikov@gmail.com>
// SPDX-License-Identifier: MIT

/*
 * Loaded via Loader so the widget keeps working (without notifications)
 * on systems where the org.kde.notification QML module is not installed.
 */
import QtQuick
import org.kde.notification

Item {
    id: helper

    signal attachRequested(string name)

    function send(title, text, sessionName) {
        var n = notifComponent.createObject(helper, {
            "title": title,
            "text": text,
            "sessionName": sessionName
        });
        n.sendEvent();
    }

    Component {
        id: notifComponent
        Notification {
            property string sessionName: ""
            componentName: "plasma_workspace"
            eventId: "notification"
            iconName: "utilities-terminal"
            autoDelete: true
            actions: NotificationAction {
                label: i18nd("plasma_applet_org.tsy.tmuxpad", "Attach")
                onActivated: helper.attachRequested(sessionName)
            }
        }
    }
}
