import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property int wsId
    required property bool active
    property bool occupied: false
    signal clicked()

    width: 24; height: 24
    radius: 6
    color: active ? Theme.bgSelected : (occupied ? Theme.bgAlt : "transparent")
    border.color: active ? Theme.accent : (occupied ? Theme.fgDim : Theme.border)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 100 } }
    Behavior on border.color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.wsId
        color: active ? Theme.fgBright : Theme.fg
        font.pixelSize: Theme.fontSmall
        font.bold: active
        font.family: Theme.family
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
