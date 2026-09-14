/**************************************************************************
 * Arc Dark Theme for SDDM — danelos
 * Palette-matched to the Desktop: Container #2b2e34, Accent #5294e2,
 * Text #b8bfca/#d3dae3, Borders #454951. Derived from maldives
 * (MIT, (c) 2013 Abdurrahman AVCI), Restyled for Arc Dark.
 ***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    // Arc Dark Palette
    property color backdrop:   "#34383d"   // Behind the Card
    property color card:       "#2b2e34"   // Panel
    property color cardBorder: "#454951"   // Panel Edge
    property color field:      "#383c43"   // Input Fields
    property color accent:     "#5294e2"   // Steel Blue
    property color accentDim:  "#3a6ea5"   // Hovered/focused Border
    property color textDim:    "#b8bfca"   // Secondary Text
    property color textBright: "#d3dae3"   // Primary Text
    property color textError:  "#f15d63"   // Error Red

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = accent
            errorMessage.text = textConstants.loginSucceeded
        }
        onLoginFailed: {
            password.text = ""
            errorMessage.color = textError
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = textError
            errorMessage.text = message
        }
    }

    // Solid Backdrop, Subtle Top-To-Bottom Shade
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(container.backdrop, 1.04) }
            GradientStop { position: 1.0; color: Qt.darker(container.backdrop, 1.04) }
        }
    }

    // Clock, Top Right, Dim
    Clock {
        id: clock
        anchors.margins: 16
        anchors.top: parent.top; anchors.right: parent.right
        color: container.textDim
        timeFont.family: "CaskaydiaCove Nerd Font"
        timeFont.pixelSize: 30
    }

    // Center Card
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.max(360, mainColumn.implicitWidth + 64)
        height: Math.max(400, mainColumn.implicitHeight + 64)
        color: container.card
        radius: 6
        border.color: container.cardBorder
        border.width: 1

        Column {
            id: mainColumn
            anchors.centerIn: parent
            spacing: 14

            // Welcome Line
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: container.textBright
                text: textConstants.welcomeText.arg(sddm.hostName)
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
            }

            // Username
            Column {
                width: parent.width
                spacing: 4
                Text {
                    width: parent.width
                    color: container.textDim
                    text: textConstants.userName
                    font.pixelSize: 11
                    font.bold: true
                }
                TextBox {
                    id: name
                    width: parent.width; height: 34
                    font.pixelSize: 14
                    textColor: container.textBright
                    color: container.field
                    borderColor: container.cardBorder
                    focusColor: container.accent
                    hoverColor: container.accentDim
                    radius: 4

                    text: userModel.lastUser

                    KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(name.text, password.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            // Password
            Column {
                width: parent.width
                spacing: 4
                Text {
                    width: parent.width
                    color: container.textDim
                    text: textConstants.password
                    font.pixelSize: 11
                    font.bold: true
                }
                PasswordBox {
                    id: password
                    width: parent.width; height: 34
                    font.pixelSize: 14
                    textColor: container.textBright
                    color: container.field
                    borderColor: container.cardBorder
                    focusColor: container.accent
                    hoverColor: container.accentDim
                    radius: 4

                    KeyNavigation.backtab: name; KeyNavigation.tab: session

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(name.text, password.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            // Session + Layout Selectors
            Row {
                spacing: 8
                width: parent.width

                Column {
                    width: (parent.width - 8) / 2
                    spacing: 4
                    Text {
                        width: parent.width
                        color: container.textDim
                        text: textConstants.session
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    ComboBox {
                        id: session
                        width: parent.width; height: 34
                        font.pixelSize: 14
                        color: container.field
                        borderColor: container.cardBorder
                        focusColor: container.accent
                        hoverColor: container.accentDim
                        menuColor: container.card
                        textColor: container.textBright
                        arrowIcon: "angle-down.png"

                        model: sessionModel
                        index: sessionModel.lastIndex

                        KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                    }
                }

                Column {
                    width: (parent.width - 8) / 2
                    spacing: 4
                    Text {
                        width: parent.width
                        color: container.textDim
                        text: textConstants.layout
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    LayoutBox {
                        id: layoutBox
                        width: parent.width; height: 34
                        font.pixelSize: 14
                        color: container.field
                        borderColor: container.cardBorder
                        focusColor: container.accent
                        hoverColor: container.accentDim
                        menuColor: container.card
                        textColor: container.textBright
                        arrowIcon: "angle-down.png"

                        KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                    }
                }
            }

            // Error / Prompt Line
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                color: container.textDim
                text: textConstants.prompt
                font.pixelSize: 11
            }

            // Action Buttons
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter
                property int btnWidth: Math.max(loginButton.implicitWidth,
                                                shutdownButton.implicitWidth,
                                                rebootButton.implicitWidth, 80) + 16

                Button {
                    id: loginButton
                    text: textConstants.login
                    width: parent.btnWidth
                    textColor: container.textBright
                    borderColor: container.accent
                    activeColor: container.accentDim
                    pressedColor: Qt.darker(container.accentDim, 1.2)

                    onClicked: sddm.login(name.text, password.text, sessionIndex)

                    KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                }

                Button {
                    id: shutdownButton
                    text: textConstants.shutdown
                    width: parent.btnWidth
                    textColor: container.textDim
                    borderColor: container.cardBorder
                    activeColor: container.accentDim
                    pressedColor: Qt.darker(container.accentDim, 1.2)

                    onClicked: sddm.powerOff()

                    KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                }

                Button {
                    id: rebootButton
                    text: textConstants.reboot
                    width: parent.btnWidth
                    textColor: container.textDim
                    borderColor: container.cardBorder
                    activeColor: container.accentDim
                    pressedColor: Qt.darker(container.accentDim, 1.2)

                    onClicked: sddm.reboot()

                    KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}