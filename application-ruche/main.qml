import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.Controls 2.15

Window {
    id: window
    width: 800
    height: 480
    visible: true
    StackView{
        id:livre
        anchors.fill: parent
        initialItem : "Page1.qml"
        property int direction: 0 // 1 = haut, -1 = bas, 2 = droite
        pushEnter: Transition {
               PropertyAnimation {
                   property: livre.direction === 2 ? "x" : "y"
                   from: (livre.direction === 1) ? -livre.height :
                         (livre.direction === -1) ? livre.height :
                         livre.width
                   to: 0
                   duration: 1000
                   easing.type: Easing.OutCubic
               }
           }
        pushExit: Transition {
               PropertyAnimation {
                   property: livre.direction === 2 ? "x" : "y"
                   from: 0
                   to: (livre.direction === 1) ? livre.height :
                       (livre.direction === -1) ? -livre.height :
                       -livre.width
                   duration: 1000
                   easing.type: Easing.OutCubic
               }
           }
        popEnter: Transition {
               PropertyAnimation {
                   property: livre.direction === 2 ? "x" : "y"
                   from: (livre.direction === 1) ? livre.height :
                         (livre.direction === -1) ? -livre.height :
                         -livre.width
                   to: 0
                   duration: 1000
                   easing.type: Easing.InCubic
               }
           }
        popExit: Transition {
               PropertyAnimation {
                   property: livre.direction === 2 ? "x" : "y"
                   from: 0
                   to: (livre.direction === 1) ? -livre.height :
                       (livre.direction === -1) ? livre.height :
                       livre.width
                   duration: 1000
                   easing.type: Easing.InCubic
               }
           }
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
