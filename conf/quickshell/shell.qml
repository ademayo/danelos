import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "widgets"

ShellRoot {
    // ------------------------------------------------------------------------
    // Top bar
    // ------------------------------------------------------------------------
    PanelWindow {
        id: bar
        anchor.fill: PanelWindowAnchor.Top
        anchor.margins: 0
        implicitHeight: 34
        color: "transparent"

        // Frosted glass panel.
        Rectangle {
            anchors.fill: parent
            color: Theme.bgPanel
            opacity: 0.92
            border.color: Theme.border
            border.width: 1
        }

        RowLayout {
            id: barLayout
            anchors.fill: parent
            spacing: Theme.pad

            // Left: workspace pills + active window title.
            RowLayout {
                spacing: 6
                Layout.leftMargin: Theme.pad
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                Repeater {
                    model: 9
                    WorkspacePill {
                        required property int index
                        wsId: index + 1
                        active: Hyprland.activeWorkspace?.id === wsId
                        occupied: {
                            if (!Hyprland.workspaces) return false;
                            for (let i = 0; i < Hyprland.workspaces.count; ++i) {
                                const ws = Hyprland.workspaces.get(i);
                                if (ws && ws.id === wsId) return (ws.windows || 0) > 0;
                            }
                            return false;
                        }
                        onClicked: Hyprland.dispatch("workspace " + wsId)
                    }
                }

                Rectangle {
                    Layout.leftMargin: 6
                    implicitWidth: Math.min(windowTitle.implicitWidth + Theme.pad * 2, 360)
                    implicitHeight: 22
                    radius: Theme.radiusSmall
                    color: Theme.bgAlt
                    visible: windowTitle.text !== ""

                    Text {
                        id: windowTitle
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.pad
                        text: Hyprland.activeWindow?.title ?? ""
                        color: Theme.fg
                        font.pixelSize: Theme.fontSmall
                        font.family: Theme.family
                        elide: Text.ElideRight
                        width: parent.width - Theme.pad * 2
                    }
                }
            }

            // Center: clock.
            Text {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Theme.fgBright
                font.pixelSize: Theme.font
                font.bold: true
                font.family: Theme.family
                text: Qt.formatDateTime(new Date(), "ddd d MMM  HH:mm")

                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd d MMM  HH:mm")
                }
            }

            // Right: system indicators.
            RowLayout {
                spacing: 8
                Layout.rightMargin: Theme.pad
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                // These chips mirror the state of the standard tray applets we
                // autostart (nm-applet, pasystray, blueman-applet). Clicking them
                // opens the matching control app; right-click/long-press behavior
                // lives in the tray icons themselves.
                IndicatorChip {
                    icon: "\uf1eb"
                    text: "Network"
                    textColor: Theme.fg
                    bgColor: Theme.bgAlt
                    onClicked: Quickshell.exec("nm-connection-editor")
                }

                IndicatorChip {
                    icon: "\uf0ea"
                    text: "Clipboard"
                    textColor: Theme.fg
                    bgColor: Theme.bgAlt
                    onClicked: Quickshell.exec("nwg-clipman")
                }

                IndicatorChip {
                    icon: Pipewire.defaultAudioSink?.audio?.muted ? "\uf026" : "\uf028"
                    text: {
                        const sink = Pipewire.defaultAudioSink;
                        if (!sink || !sink.audio) return "--";
                        return Math.round(sink.audio.volume * 100) + "%";
                    }
                    textColor: Pipewire.defaultAudioSink?.audio?.muted ? Theme.fgDim : Theme.fg
                    bgColor: Theme.bgAlt
                    onClicked: Quickshell.exec("pavucontrol-qt")
                }

                IndicatorChip {
                    icon: {
                        const dev = UPower.displayDevice;
                        if (!dev || !dev.ready) return "\uf244";
                        if (dev.percentage <= 20) return "\uf243";
                        if (dev.percentage <= 40) return "\uf242";
                        if (dev.percentage <= 60) return "\uf241";
                        if (dev.percentage <= 80) return "\uf240";
                        return "\uf240";
                    }
                    text: {
                        const dev = UPower.displayDevice;
                        if (!dev || !dev.ready) return "--";
                        return Math.round(dev.percentage) + "%";
                    }
                    urgent: {
                        const dev = UPower.displayDevice;
                        return dev && dev.ready && dev.percentage <= 20 && dev.state === 2; // Discharging
                    }
                    textColor: Theme.fg
                    bgColor: Theme.bgAlt
                    onClicked: Quickshell.exec("xfce4-power-manager-settings")
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    // App launcher popup
    // ------------------------------------------------------------------------
    PanelWindow {
        id: launcher
        visible: false
        anchor.center: true
        width: 720
        height: 480
        color: "transparent"

        // Drop shadow / frosted backdrop.
        Rectangle {
            anchors.fill: parent
            color: Theme.bg
            opacity: 0.96
            radius: Theme.radius
            border.color: Theme.border
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.padLarge
            spacing: Theme.pad

            Text {
                text: "Launch Application"
                color: Theme.fgBright
                font.pixelSize: Theme.fontLarge
                font.bold: true
                font.family: Theme.family
                Layout.bottomMargin: 4
            }

            TextField {
                id: search
                Layout.fillWidth: true
                implicitHeight: 42
                placeholderText: "Type to search…"
                color: Theme.fg
                placeholderTextColor: Theme.fgDim
                selectionColor: Theme.bgSelected
                selectedTextColor: Theme.fgBright
                font.pixelSize: Theme.font
                font.family: Theme.family
                background: Rectangle {
                    color: Theme.bgAlt
                    radius: Theme.radiusSmall
                    border.color: search.activeFocus ? Theme.borderFocus : "transparent"
                    border.width: search.activeFocus ? 2 : 0
                }

                Keys.onEscapePressed: launcher.visible = false
                Keys.onReturnPressed: {
                    if (filteredList.count > 0) {
                        filteredList.currentItem.launch();
                    }
                }
                Keys.onDownPressed: filteredList.incrementCurrentIndex()
                Keys.onUpPressed: filteredList.decrementCurrentIndex()

                // Show prompt hint.
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    text: "ESC to close"
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSmall
                    font.family: Theme.family
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.bgAlt
                radius: Theme.radiusSmall

                ListView {
                    id: filteredList
                    anchors.fill: parent
                    anchors.margins: Theme.padSmall
                    clip: true
                    spacing: 2
                    currentIndex: 0
                    highlightMoveDuration: 120
                    highlight: Rectangle {
                        color: Theme.bgSelected
                        radius: Theme.radiusSmall
                    }

                    model: {
                        const needle = search.text.toLowerCase();
                        const entries = DesktopEntries.entries || [];
                        return entries.filter(e =>
                            e.name.toLowerCase().includes(needle) ||
                            (e.comment && e.comment.toLowerCase().includes(needle)) ||
                            (e.categories && e.categories.some(c => c.toLowerCase().includes(needle)))
                        ).slice(0, 24);
                    }

                    delegate: Rectangle {
                        id: itemBg
                        width: filteredList.width
                        height: 46
                        radius: Theme.radiusSmall
                        color: ListView.isCurrentItem ? Theme.bgSelected : "transparent"

                        function launch() {
                            const entry = modelData;
                            const cmd = entry.executable || entry.exec;
                            if (cmd) {
                                Quickshell.exec(cmd);
                                launcher.visible = false;
                                search.text = "";
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.pad
                            anchors.rightMargin: Theme.pad
                            spacing: Theme.pad

                            IconImage {
                                source: modelData.iconName || modelData.icon || "application-x-executable"
                                width: 26; height: 26
                                color: ListView.isCurrentItem ? Theme.fgBright : Theme.fg
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.name
                                    color: ListView.isCurrentItem ? Theme.fgBright : Theme.fg
                                    font.pixelSize: Theme.font
                                    font.bold: true
                                    font.family: Theme.family
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.comment || ""
                                    color: ListView.isCurrentItem ? Theme.fgBright : Theme.fgDim
                                    font.pixelSize: Theme.fontSmall
                                    font.family: Theme.family
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    visible: modelData.comment
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: filteredList.currentIndex = index
                            onClicked: launch()
                        }
                    }

                    Keys.onReturnPressed: {
                        if (currentItem) currentItem.launch();
                    }
                    Keys.onEscapePressed: launcher.visible = false

                    // Empty state.
                    Text {
                        anchors.centerIn: parent
                        text: "No applications found"
                        color: Theme.fgDim
                        font.pixelSize: Theme.font
                        font.family: Theme.family
                        visible: parent.count === 0 && search.text !== ""
                    }
                }
            }
        }
    }
}
