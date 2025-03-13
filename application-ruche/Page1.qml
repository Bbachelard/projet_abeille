import QtQuick 2.15
import QtQuick.Controls 2.15

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
                livre.push("Page2.qml");
            }
        }

        Button{
            text:"Utilisateur"
            width: 200
            height: 50
            onClicked: {
                livre.direction=-1;
                livre.push("Page3.qml")
            }
        }

        Button{
            text:"ruche"
            width: 200
            height: 50
            onClicked: {
                livre.push("Page4A.qml")
            }
        }
        Button{
            text:"super dmin"
            width: 200
            height: 50
            onClicked: {
                livre.push("Page2A.qml")
            }
        }
}}


