import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: clipboardPopup
    visible: false
    anchor.center: true
    width: 560
    height: 420
    color: "transparent"

    property var history: []

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
            placeholderText: "Filter clipboard…"
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
            Keys.onEscapePressed: clipboardPopup.visible = false
            Keys.onReturnPressed: { if (filteredList.count > 0) filteredList.currentItem.copy(); }
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
                    return clipboardPopup.history.filter(line => line.preview.toLowerCase().includes(needle)).slice(0, 40);
                }

                delegate: Rectangle {
                    id: itemBg
                    width: filteredList.width
                    height: 38
                    radius: Theme.radiusSmall
                    color: ListView.isCurrentItem ? Theme.bgSelected : (mouseArea.containsMouse ? Theme.bgHover : "transparent")

                    function copy() {
                        Quickshell.exec("cliphist decode " + modelData.id + " | wl-copy");
                        clipboardPopup.visible = false;
                        search.text = "";
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.pad
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.pad
                        text: modelData.preview
                        color: ListView.isCurrentItem ? Theme.fgBright : Theme.fg
                        font.pixelSize: Theme.fontSmall
                        font.family: Theme.family
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: filteredList.currentIndex = index
                        onClicked: copy()
                    }
                }

                Keys.onReturnPressed: { if (currentItem) currentItem.copy(); }
                Keys.onEscapePressed: clipboardPopup.visible = false

                Text {
                    anchors.centerIn: parent
                    text: "Clipboard empty"
                    color: Theme.fgDim
                    font.pixelSize: Theme.font
                    font.family: Theme.family
                    visible: parent.count === 0
                }
            }
        }
    }

    function load() {
        Quickshell.execAsync("cliphist list", (exitCode, stdout) => {
            const lines = stdout.split("\n").filter(line => line.trim() !== "");
            clipboardPopup.history = lines.map(line => {
                const tab = line.indexOf("\t");
                if (tab < 0) return { id: "", preview: line };
                return { id: line.substring(0, tab), preview: line.substring(tab + 1) };
            });
        });
    }

    onVisibleChanged: { if (visible) { load(); search.forceActiveFocus(); } }
}
