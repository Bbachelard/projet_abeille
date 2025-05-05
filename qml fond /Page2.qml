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
            onPressed: Qt.inputMethod.show()
        }
        TextField {
            id: passwordField
            width: 300
            placeholderText: "Mot de passe"
            font.pixelSize: 18
            echoMode: TextInput.Password
            onPressed: Qt.inputMethod.show()
        }
        Button {
            text: "Se connecter"
            width: 200
            height: 40
            onClicked: {
                if (usernameField.text === "" || passwordField.text === "") {
                    console.log("Veuillez remplir tous les champs.");
                } else {
                    console.log("Identifiants saisis : " + usernameField.text + ", " + passwordField.text);
                }
                livre.direction = 2;
                livre.push(page4)
            }
        }
    }
}
