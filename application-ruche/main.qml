import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.Controls 2.15


/*

import "qrc:/qml/Page1.qml" as Page1
import "qrc:/qml/Page2.qml" as Page2
import "qrc:/qml/Page3.qml" as Page3
import "qrc:/qml/Page4.qml" as Page4
*/

Window {
    id: window
    width: 800
    height: 480
    visible: true
    StackView{
        id:livre
        anchors.fill: parent
        initialItem : page1
        property int direction: 0 // 1 = haut, -1 = bas, 2 = droite
        pushEnter: Transition {
               PropertyAnimation {
                   property: livre.direction === 2 ? "x" : "y"
                   from: (livre.direction === 1) ? -livre.height :
                         (livre.direction === -1) ? livre.height :
                         livre.width
                   to: 0
                   duration: 1500
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
                   duration: 1500
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
                   duration: 1500
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
                   duration: 1500
                   easing.type: Easing.InCubic
               }
           }
    }
    Component{
        id:page1;
        Item {
            width: parent.width
            height: parent.height
            Image {
                source: "qrc:/fond1.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                z: -1
            }
            Button {
                text: "Quitter"
                width: 100
                height: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                }
                onClicked: Qt.quit()
            }
            Column {
                spacing: 20
                anchors.centerIn: parent
                Button{
                    text:"Administrateur"
                    width: 200
                    height: 50
                    onClicked: {
                        livre.direction=1;
                        livre.push(page2);
                    }
                }
                Button{
                    text:"Utilisateur"
                    width: 200
                    height: 50
                    onClicked: {
                        livre.direction=-1;
                        livre.push(page3)
                    }
                }
            }
        }
    }
    Component{
        id: page2
        Item {
            width: parent.width
            height: parent.height
            Image {
                source: "qrc:/fond2.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                z: -1
            }
            Button {
                text: "retour"
                width: 100
                height: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                    leftMargin: 680
                }
                onClicked: {
                    livre.direction = 1;
                    livre.pop()
                }
            }
            Column {
                        spacing: 20
                        anchors.centerIn: parent
                        TextField {
                            id: usernameField
                            width: 300
                            placeholderText: "Nom d'utilisateur"
                            font.pixelSize: 18
                            focus: true
                            onPressed: {
                                Qt.inputMethod.show()
                            }
                        }
                        TextField {
                            id: passwordField
                            width: 300
                            placeholderText: "Mot de passe"
                            onPressed: {
                                Qt.inputMethod.show()
                            }
                            font.pixelSize: 18
                            echoMode: TextInput.Password

                        }
                        Button {
                            text: "Se connecter"
                            width: 200
                            height: 40
                            onClicked:{
                                if (usernameField.text === "" || passwordField.text === "") {
                                    console.log("Veuillez remplir tous les champs.");
                                }else{
                                    if (admin.authentification(usernameField.text, passwordField.text)) {
                                    console.log("Connexion réussie !");
                                    livre.direction = 2;
                                    livre.push(page4); // Aller à la page suivante
                                } else {
                                    console.log("Identifiants incorrects !");
                                }
                                }
                            }
                        }
            }

        }
    }
    Component {
        id: page3
        Item {
            width: parent.width
            height: parent.height
            Image {
                source: "qrc:/fond3.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                z: -1
            }
            Button {
                text: "retour"
                width: 100
                height: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                    leftMargin: 680
                }
                onClicked: {
                    livre.direction = -1;
                    livre.pop()
                }
            }


            Button {
                text: "ruche"
                anchors.centerIn: parent
                onClicked:{
                    livre.direction = 2;
                    livre.push(page4)
                }
            }
        }
    }
    Component {
        id: page4
        Item {
            width: parent.width
            height: parent.height
            Image {
                source: "qrc:/fond1.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                z: -1
            }
            Button {
                text: "retour"
                width: 100
                height: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                    leftMargin: 680
                }
                onClicked: {
                    livre.direction = 2;
                    livre.pop()
                }
            }

        }}
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
