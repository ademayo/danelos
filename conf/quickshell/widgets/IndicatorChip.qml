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

    implicitWidth: row.implicitWidth + Theme.pad * 2
    implicitHeight: 22
    radius: Theme.radiusSmall
    color: urgent ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.25) : bgColor
    border.color: urgent ? Theme.red : "transparent"
    border.width: urgent ? 1 : 0

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: iconLabel
            color: urgent ? Theme.red : Theme.accent2
            font.pixelSize: Theme.fontSmall
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
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
