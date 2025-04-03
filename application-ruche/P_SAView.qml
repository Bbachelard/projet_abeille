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
                        height: 240
                        dim: true
                        modal: false
                        focus: true
                        closePolicy:Popup.CloseOnPressOutside
                        z: 100
                        anchors.centerIn: page.top

                        Column{
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 10
                             z: 200
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
                            ComboBox {
                                id: gradeField
                                width: 400
                                model: ["1 - User", "2 - Admin", "3 - Superadmin"]
                                font.pixelSize: 18

                                // Personnalisation du popup existant
                                popup.z: 999 // Valeur élevée pour être au premier plan

                                // Alternative: définir plus de propriétés du popup
                                popup.font.pixelSize: 18
                                popup.width: width
                            }
                            Text {
                                id: errorMessage4
                                text: ""
                                color: "yellow"
                                font.pixelSize: 18
                                font.bold: true
                                y: +80
                                x: +450
                            }

                            Timer {
                                id: hideError4
                                interval: 3000
                                onTriggered: errorMessage4Rect.visible = false
                            }

                            Button {
                                text: "Ajouter Utilisateur"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked: if(usernameField.text === "" || passwordField.text === "" || gradeField.currentIndex === -1){
                                               console.log("Veuillez remplir le champ.");
                                               errorMessage4.text = "Veuillez remplir le champ";
                                               errorMessage4.visible = true;
                                               hideError4.start()}
                                            else{
                                               dManager.adduser(usernameField.text, passwordField.text, gradefield.currentindex)
                                            }}
                        }
        }
                Popup {
                        id: modif_mdp
                        width: 350
                        height: 250
                        modal: true
                        focus: true
                        closePolicy:Popup.CloseOnPressOutside
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
                            Text {
                                id: errorMessage
                                text: ""
                                color: "yellow"
                                font.pixelSize: 18
                                font.bold: true
                                y: +80
                                x: +450
                            }

                            Timer {
                                id: hideError
                                interval: 3000
                                onTriggered: errorMessageRect.visible = false
                            }
                            Button {
                                text: "Modifier MDP Utilisateur"
                                anchors.bottom: parent
                                width: 200
                                height: 40
                                onClicked: if(username_mmdp.text === ""){
                                               console.log("Veuillez remplir le champ.");
                                               errorMessage.text = "Veuillez remplir le champ";
                                               errorMessage.visible = true;
                                               hideError.start()}
                                            else{
                                               if(dManager.verifUser(username_mmdp))
                                                {
                                                   modif_mdp_page.open()
                                                }
                                            }
            }
        }
    }
                        Popup {
                            id: modif_grade
                            width: 350
                            height: 250
                            modal: true
                            focus: true
                            parent: page
                            closePolicy: Popup.CloseOnPressOutside
                            z: 100

                            Column {
                                anchors.centerIn: parent
                                width: parent.width
                                spacing: 10

                                TextField {
                                    id: username_mgrade
                                    width: 300
                                    placeholderText: "Nom d'utilisateur"
                                    font.pixelSize: 18
                                    focus: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    onPressed: {
                                        Qt.inputMethod.show()
                                    }
                                    echoMode: TextInput.Normal // Changé de 'id' à 'Normal'
                                }

                                ComboBox {
                                    id: grade
                                    width: 300
                                    model: ["1 - User", "2 - Admin", "3 - Superadmin"]
                                    font.pixelSize: 18

                                    // Personnalisation du popup existant
                                    popup.z: 999 // Valeur élevée pour être au premier plan

                                    // Alternative: définir plus de propriétés du popup
                                    popup.font.pixelSize: 18
                                    popup.width: width
                                }
                                Text {
                                    id: errorMessage2
                                    text: ""
                                    color: "yellow"
                                    font.pixelSize: 18
                                    font.bold: true
                                    y: +80
                                    x: +450
                                }

                                Timer {
                                    id: hideError2
                                    interval: 3000
                                    onTriggered: errorMessage2Rect.visible = false
                                }

                                Button {
                                    text: "Confirmer modification"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 200
                                    height: 40
                                    onClicked: {
                                        if (username_mgrade.text === "" || grade.currentIndex === -1) {
                                            console.log("Veuillez remplir tous les champs.");
                                            errorMessage2.text = "Veuillez remplir tous les champs";
                                            errorMessage2.visible = true;
                                            hideError2.start();
                                        } else {
                                            dManager.modifgrade(username_mgrade.text, grade.currentIndex)
                                            // Par exemple: dManager.modifGrade(username_mgrade.text, gradefield.text)
                                            console.log("Grade modifié");
                                            modif_grade.close(); // Fermer le popup après modification
                                        }
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
                            Text {
                                id: errorMessage3
                                text: ""
                                color: "yellow"
                                font.pixelSize: 18
                                font.bold: true
                                y: +80
                                x: +450
                            }

                            Timer {
                                id: hideError3
                                interval: 3000
                                onTriggered: errorMessage3Rect.visible = false
                            }
                            Button {
                                text: "Modifier mot de passe"
                                anchors.horizontalCenter:
                                parent.horizontalCenter
                                width: 200
                                height: 40
                                onClicked:{
                                        if (password.text === "") {
                                            console.log("Veuillez remplir le champ.");
                                            errorMessage3.text = "Veuillez remplir le champ";
                                            errorMessage3.visible = true;
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




