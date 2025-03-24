import QtQuick 2.15
import QtQuick.Controls 2.15

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
    Button {
        text: "modifier utilisateurs"
        width: 250
        height: 50
        onClicked: popup.open()
   }

        Popup {
                id: popup
                width: 350
                height: 250
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                z: 100

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "lightgray"
                    border.color: "gray"

                    Column {
                        anchors.centerIn: parent
                        anchors.rightMargin: 20
                        width: parent.width
                        spacing: 10


                        Button {
                            text: "Ajouter Utilisateur"
                            width: 200
                            height: 40
                            onClicked: create_user.open()}

                        Button {
                            text: "Modifier MDP Utilisateur"
                            width: 200
                            height: 40
                            onClicked: modif_mdp.open()}
                        Button {
                            text: "Modifier grade"
                            width: 200
                            height: 40
                            onClicked: modif_grade.open()

                        }
                        Button {
                            text: "fermer"
                            width: 100
                            height: 40
                            anchors.bottom: parent
                            onClicked: popup.close()

                        }
                    }



                    }
                Popup {
                        id: create_user
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                        z: 100

                        Column{
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 10
                            TextField {
                                id: usernameField
                                width: 300
                                placeholderText: "Nom d'utilisateur"
                                font.pixelSize: 18
                                focus: true
                                onPressed: {
                                    Qt.inputMethod.show()
                                }
                                echoMode: TextInput.id
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
                                text: "Ajouter Utilisateur"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked: create_user.open()}
                        }
        }
                Popup {
                        id: modif_mdp
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                        z: 100

                        Column{
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 10
                            TextField {
                                id: username_mmdp
                                width: 300
                                placeholderText: "Nom d'utilisateur"
                                font.pixelSize: 18
                                focus: true
                                onPressed: {
                                    Qt.inputMethod.show()
                              }
                                echoMode: TextInput.id
                            }
                            Button {
                                text: "Modifier MDP Utilisateur"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked: modif_mdp.open()}


            }
        }
                Popup {
                        id: modif_grade
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                        z: 100

                        Column{
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 10
                            TextField {
                                id: username_mgrade
                                width: 300
                                placeholderText: "Nom d'utilisateur"
                                font.pixelSize: 18
                                focus: true
                                onPressed: {
                                    Qt.inputMethod.show()
                                }
                                echoMode: TextInput.id
                            }
                            TextField {
                                id: gradefield
                                width: 300
                                placeholderText: "nouveau grade"
                                onPressed: {
                                    Qt.inputMethod.show()
                                }
                                font.pixelSize: 18
                                echoMode: TextInput.id}
                            Button {
                                text: "Modifier grade"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked:{ modif_grade.open() ;
                                    gradefield.clear();
                                    username_mgrade.clear();}



                            }
                        }
                }

    }
}
