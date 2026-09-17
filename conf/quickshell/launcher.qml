import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ShellRoot {
    PanelWindow {
        id: launcher
        visible: true
        anchor.center: true
        width: 720
        height: 480
        color: "transparent"

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

                Keys.onEscapePressed: Qt.quit()
                Keys.onReturnPressed: {
                    if (filteredList.count > 0) {
                        filteredList.currentItem.launch();
                    }
                }
                Keys.onDownPressed: filteredList.incrementCurrentIndex()
                Keys.onUpPressed: filteredList.decrementCurrentIndex()

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
                        width: filteredList.width
                        height: 46
                        radius: Theme.radiusSmall
                        color: ListView.isCurrentItem ? Theme.bgSelected : "transparent"

                        function launch() {
                            const entry = modelData;
                            const cmd = entry.executable || entry.exec;
                            if (cmd) {
                                Quickshell.exec(cmd);
                                Qt.quit();
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
                    Keys.onEscapePressed: Qt.quit()

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
