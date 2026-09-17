import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "widgets"

ShellRoot {
    PanelWindow {
        id: bar
        anchor.fill: PanelWindowAnchor.Top
        anchor.margins: 0
        implicitHeight: 36
        color: "transparent"

        Rectangle {
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 6
            color: Theme.shadow
            opacity: 0.25
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.panelGlass
            border.color: Theme.border
            border.width: 1

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(1, 1, 1, 0.03)
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: Theme.pad

            RowLayout {
                spacing: 7
                Layout.leftMargin: Theme.padLarge
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
                    Layout.leftMargin: 8
                    implicitWidth: Math.min(windowTitle.implicitWidth + Theme.pad * 2, 360)
                    implicitHeight: 22
                    radius: Theme.radiusSmall
                    color: Theme.bgAlt
                    border.color: Theme.border
                    border.width: 1
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

            Rectangle {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                implicitWidth: clockText.implicitWidth + Theme.pad * 3
                implicitHeight: 24
                radius: 12
                color: Theme.bgAlt
                border.color: Theme.border
                border.width: 1

                Text {
                    id: clockText
                    anchors.centerIn: parent
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
            }

            RowLayout {
                spacing: 7
                Layout.rightMargin: Theme.padLarge
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                IndicatorChip {
                    icon: "\uf1eb"
                    text: ""
                    onClicked: Quickshell.exec("nm-connection-editor")
                }

                IndicatorChip {
                    icon: "\uf0ea"
                    text: ""
                    onClicked: clipboardPopup.visible = true
                }

                IndicatorChip {
                    icon: Pipewire.defaultAudioSink?.audio?.muted ? "\uf026" : "\uf028"
                    text: {
                        const sink = Pipewire.defaultAudioSink;
                        if (!sink || !sink.audio) return "";
                        return Math.round(sink.audio.volume * 100) + "%";
                    }
                    textColor: Pipewire.defaultAudioSink?.audio?.muted ? Theme.fgDim : Theme.fg
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
                        if (!dev || !dev.ready) return "";
                        return Math.round(dev.percentage) + "%";
                    }
                    urgent: {
                        const dev = UPower.displayDevice;
                        return dev && dev.ready && dev.percentage <= 20 && dev.state === 2;
                    }
                    onClicked: Quickshell.exec("cbatticon")
                }

                IndicatorChip {
                    icon: "\uf011"
                    text: ""
                    textColor: Theme.fgBright
                    bgColor: Theme.accent
                    onClicked: Quickshell.exec("wlogout")
                }
            }
        }
    }

    Clipboard {
        id: clipboardPopup
    }

    PanelWindow {
        id: launcher
        visible: false
        anchor.center: true
        width: 680
        height: 440
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.shadow
            radius: Theme.radiusLarge
            opacity: 0.35
            anchors.margins: -8
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.bg
            opacity: 0.97
            radius: Theme.radiusLarge
            border.color: Theme.border
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.padLarge
            spacing: Theme.pad

            TextField {
                id: search
                Layout.fillWidth: true
                implicitHeight: 40
                placeholderText: "Search…"
                color: Theme.fg
                placeholderTextColor: Theme.fgDim
                selectionColor: Theme.bgSelected
                selectedTextColor: Theme.fgBright
                font.pixelSize: Theme.font
                font.family: Theme.family
                background: Rectangle {
                    color: Theme.bgAlt
                    radius: Theme.radius
                    border.color: search.activeFocus ? Theme.borderFocus : Theme.border
                    border.width: 1
                }

                Keys.onEscapePressed: launcher.visible = false
                Keys.onReturnPressed: {
                    if (filteredList.count > 0) {
                        filteredList.currentItem.launch();
                    }
                }
                Keys.onDownPressed: filteredList.incrementCurrentIndex()
                Keys.onUpPressed: filteredList.decrementCurrentIndex()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.bgAlt
                radius: Theme.radius
                border.color: Theme.border
                border.width: 1

                ListView {
                    id: filteredList
                    anchors.fill: parent
                    anchors.margins: Theme.padSmall
                    clip: true
                    spacing: 2
                    currentIndex: 0
                    highlightMoveDuration: 100
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
                        ).slice(0, 20);
                    }

                    delegate: Rectangle {
                        id: itemBg
                        width: filteredList.width
                        height: 42
                        radius: Theme.radiusSmall
                        color: ListView.isCurrentItem ? Theme.bgSelected : (mouseArea.containsMouse ? Theme.bgHover : "transparent")

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
                                width: 20; height: 20
                                color: ListView.isCurrentItem ? Theme.fgBright : Theme.fg
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.name
                                    color: ListView.isCurrentItem ? Theme.fgBright : Theme.fg
                                    font.pixelSize: Theme.font
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
                            id: mouseArea
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
