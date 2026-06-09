import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nd("plasma_applet_org.tsy.tmuxpad", "General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.tsy.tmuxpad", "AI Agents")
        icon: "applications-development"
        source: "configAgents.qml"
    }
}
