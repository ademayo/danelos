import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property alias text: label.text
    property alias icon: iconLabel.text
    property color textColor: Theme.fg
    property color bgColor: Theme.bgAlt
    property bool urgent: false
    signal clicked()

    implicitWidth: Math.max(22, row.implicitWidth + Theme.pad * 2)
    implicitHeight: 22
    radius: 5
    color: urgent ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.18) : bgColor
    border.color: urgent ? Theme.red : Theme.border
    border.width: 1
    opacity: mouseArea.containsMouse ? 0.95 : 1

    Behavior on opacity { NumberAnimation { duration: 100 } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: iconLabel
            color: urgent ? Theme.red : Theme.accent
            font.pixelSize: Theme.fontSmall
            font.family: Theme.mono
            visible: text !== ""
        }

        Text {
            id: label
            color: urgent ? Theme.fgBright : textColor
            font.pixelSize: Theme.fontSmall
            font.family: Theme.family
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
