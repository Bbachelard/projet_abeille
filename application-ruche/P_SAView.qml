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
    Timer {
        id: hideError
        interval: 3000
        onTriggered: errorMessage.visible = false
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
                            onClicked:{ modif_grade.parent = Overlay.overlay
                            modif_grade.open()}
                        }
                    }
                Popup {
                        id: create_user
                        width: 450
                        height: 200
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnPressOutside
                        parent: Overlay.overlay
                        z: 2000
                        anchors.centerIn: page.top
                        Text {
                            id: errorMessage
                            text: ""
                            color: "yellow"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                            visible: false
                        }
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
                                onFocusChanged: {
                                    if (focus) {
                                        Qt.inputMethod.show();
                                    }
                                }
                                echoMode: TextInput.id
                            }
                            TextField {
                                id: passwordField
                                width: 400
                                placeholderText: "Mot de passe"
                                onFocusChanged: {
                                                if (focus) {
                                                    Qt.inputMethod.show();
                                                }
                                            }
                                font.pixelSize: 18
                                echoMode: TextInput.Password
                            }
                            TextField {
                                id: gradeField
                                width: 400
                                placeholderText: "grade (1=user;2=admin;3=superadmin)"
                                onFocusChanged: {
                                    if (focus) {
                                        Qt.inputMethod.show();
                                    }
                                }
                                font.pixelSize: 18
                                echoMode: TextInput.grade
                            }
                            Button {
                                text: "Ajouter Utilisateur"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked:if (usernameField.text === "" || passwordField.text === "" || gradeField.text === "") {
                                              console.log("Veuillez remplir tous les champs.");
                                              errorMessage.text = "Veuillez remplir tous les champs";
                                              errorMessage.visible = true;
                                              hideError.start();
                                          } else {
                                              add_o.open();
                                          }
                            }
                        }
                        Popup {
                            id: add_o
                            width: 450
                            height: 200
                            modal: true
                            focus: true
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                            parent: Overlay.overlay
                            z: 3000  // Z supérieur à celui de create_user (2000) pour s'afficher devant
                            anchors.centerIn: parent  // Centre la popup dans son parent

                            Column {
                                anchors.centerIn: parent
                                width: parent.width - 40  // Marge sur les côtés
                                spacing: 20

                                Text {
                                    id: name
                                    width: parent.width
                                    text: qsTr("Êtes-vous sûr de vouloir ajouter cet utilisateur ?")
                                    horizontalAlignment: Text.AlignHCenter  // Centre le texte horizontalement
                                    font.pixelSize: 16
                                }

                                Row {
                                    spacing: 20
                                    anchors.horizontalCenter: parent.horizontalCenter  // Centre les boutons

                                    Button {
                                        text: "Oui"
                                        width: 120
                                        height: 40
                                        onClicked: {
                                            userManager.adduser(usernameField.text, passwordField.text, parseInt(gradeField.text))
                                            add_o.close()
                                            create_user.close()  // Ferme aussi la première popup après ajout
                                        }
                                    }

                                    Button {
                                        text: "Non"
                                        width: 120
                                        height: 40
                                        onClicked: add_o.close()  // Ferme seulement cette popup
                                    }
                                }
                            }
                        }

        }
                Popup {
                        id: modif_mdp
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        parent: Overlay.overlay
                        z: 90
                        Text {
                            id: errorMessagem
                            text: ""
                            color: "yellow"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                            visible: false
                        }
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
                                onClicked: if(username_mmdp.text ===""){
                                                console.log("Veuillez remplir le champ.");
                                                errorMessagem.text = "Veuillez remplir le champ";
                                                errorMessagem.visible = true;
                                                hideError.start();
                                           }
                                           else{
                                               if(userManager.verifUser(username_mmdp.text)){
                                                   modif_mdp_page.open()}
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
                        parent: Overlay.overlay
                        z: 90

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
                                onClicked:{ if(username_mgrade.text ==="" || gradefield.text === "" ){
                                        console.log("Veuillez remplir les champ.");
                                        errorMessagem.text = "Veuillez remplir les champ";
                                        errorMessagem.visible = true;
                                        hideError.start();
                                   }
                                   else{
                                        userManager.modifgrade(username_mgrade.text, parseInt(gradefield.text))
                                        modif_grade.close();}

                                }
                            }
                        }
                }
                Popup {
                        id: modif_mdp_page
                        width: page.width
                        height: page.height
                        modal: true
                        focus: true
                        parent: Overlay.overlay
                        z: 90
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
                                            userManager.modifpw(username_mmdp.text, password.text)
                                            console.log("mot de passes modifié");
                                            modif_mdp_page.close();

                                        }
                                }
                        }
                }
          }
    }
}
}
