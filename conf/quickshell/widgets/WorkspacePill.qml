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

    width: 26; height: 26
    radius: 7
    color: active ? Theme.bgSelected : (occupied ? Theme.bgHover : "transparent")
    border.color: active ? Theme.bgSelected : Theme.fgDim
    border.width: active ? 0 : 1

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: root.wsId
        color: active ? Theme.fgBright : Theme.fg
        font.pixelSize: Theme.fontSmall
        font.bold: true
        font.family: Theme.family
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
