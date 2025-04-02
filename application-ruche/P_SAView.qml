import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: page
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
    anchors.centerIn: parent
    anchors.horizontalCenter:
    parent.horizontalCenter
    anchors.rightMargin: 20
    width: parent.width
    spacing: 10


    Button {
        text: "Ajouter Utilisateur"

        x: +300
        width: 200
        height: 40
        onClicked: create_user.open()}

    Button {
        text: "Modifier MDP Utilisateur"
        x: +250
        width: 200
        height: 40
        onClicked: modif_mdp.open()}
    Button {
        text: "Modifier grade"
        x:+300
        width: 200
        height: 40
        onClicked: modif_grade.open()
    }
}
Popup {
    id: create_user
    width: 450
    height: 200
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    z: 100
    anchors.centerIn: page.top

    Column{
        anchors.centerIn: parent
        width: parent.width
        spacing: 10
        TextField {
            id: usernameField
            width: 400
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
            width: 400
            placeholderText: "Mot de passe"
            onPressed: {
                Qt.inputMethod.show()
            }
            font.pixelSize: 18
            echoMode: TextInput.Password
        }
        TextField {
            id: gradeField
            width: 400
            placeholderText: "grade (1=user;2=admin;3=superadmin)"
            onPressed: {
                Qt.inputMethod.show()
            }
            font.pixelSize: 18
            echoMode: TextInput.grade
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
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
                                onClicked: if(dManager.verifuser(username_mmdp)){
                                           modif_mdp_page.open()}
                                           else{console.log("Veuillez remplir le champ.");
                                               errorMessage.text = "Veuillez remplir le champ";
                                               errorMessage.visible = true;
                                               hideError.start();
                                           }
            }
        }
                Popup {
                        id: modif_grade
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
                Popup {
                        id: modif_mdp_page
                        width: page.width
                        height: page.height
                        modal: true
                        focus: true
                        z: 100
                        anchors.centerIn: page

                        Column{
                            anchors.centerIn: parent
                            spacing: 10
                            width: page.width
                            height:page.height/2

                            TextField {
                                id: password
                                width: 400
                                placeholderText: "Nouveau Mot de passe"
                                anchors.horizontalCenter:
                                parent.horizontalCenter
                                onPressed: {
                                    Qt.inputMethod.show()
                                }
                                font.pixelSize: 18
                                echoMode: TextInput.Password
                            }

                            Button {
                                text: "Modifier mot de passe"
                                anchors.horizontalCenter:
                                parent.horizontalCenter
                                width: 200
                                height: 40
                                onClicked:{ onClicked:{
                                        if (password.text === "") {
                                            console.log("Veuillez remplir le champ.");
                                            errorMessage.text = "Veuillez remplir le champ";
                                            errorMessage.visible = true;
                                            hideError.start();
                                        }else{
                                            dManager.modifpw(password.text, username_mmdp.text)
                                            console.log("mot de passes modifié");

                                        }
                                }
                        }
                }
          }
    }
}
}
