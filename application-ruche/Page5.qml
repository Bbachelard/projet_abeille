import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    width: parent.width
    height: parent.height

    property var ruche
    property var rucheData: rucheData || []

    Image {
        source: "qrc:/fond5.png"
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
        Text {
            text: "Ruche ID: " + ruche.getId()
            font.pixelSize: 24
        }

        ListView {
            width: parent.width
            height: 320
            model: rucheData  // Utilisation directe de rucheData transmis par Page4A.qml
            delegate: Column {
                spacing: 5

                Text {
                    text: "Température: " + modelData.temperature + " °C"
                    font.pixelSize: 18
                }
                Text {
                    text: "Humidité: " + modelData.humidity + " %"
                    font.pixelSize: 18
                }
                Text {
                    text: "Masse: " + modelData.mass + " kg"
                    font.pixelSize: 18
                }
                Text {
                    text: "Pression: " + modelData.pression + " hPa"
                    font.pixelSize: 18
                }
                Text {
                    text: "date: " + modelData.dateTime
                    font.pixelSize: 18
                }
                Text {
                    text: "-------------------"
                    font.pixelSize: 18
                }
            }
        }
    }
}
