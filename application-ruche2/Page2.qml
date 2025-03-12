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
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"

                    Text {
                        id: errorMessage
                        text: ""
                        color: "yellow"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.centerIn: parent
                        visible: false
                    }
                }
                Timer {
                    id: hideError
                    interval: 3000
                    onTriggered: errorMessage.visible = false
                }
                Button {
                    text: "Se connecter"
                    width: 200
                    height: 40
                    onClicked:{
                        if (usernameField.text === "" || passwordField.text === "") {
                            console.log("Veuillez remplir tous les champs.");
                            errorMessage.text = "Veuillez remplir tous les champs!";
                            errorMessage.visible = true;
                            hideError.start();
                        }else{
                            if (admin.authentification(usernameField.text, passwordField.text)) {
                            console.log("Connexion réussie !");
                            livre.direction = 2;
                            livre.push("Page4A.qml");
                        } else {
                            console.log("Identifiants incorrects !");
                            errorMessage.text = "Identifiants incorrects !";
                            errorMessage.visible = true;
                            hideError.start();
                            }
                        }
                    }
                }
    }
}
