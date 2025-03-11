import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    width: parent.width
    height: parent.height

    property var ruche
    property var rucheData: rucheData || []
    property var capteursData: []

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
        Button {
            text: "Charger les données"
            onClicked: {
                capteursData = dManager.getRucheData();
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 100
            anchors.top: parent.top
            anchors.topMargin: 80
            model: capteursData
            delegate: Column {
                width: parent.width
                spacing: 5
                padding: 10

                Rectangle {
                    width: parent.width - 20
                    height: 120
                    color: "#eeeeee"
                    radius: 10
                    border.color: "#aaaaaa"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "🆔 Capteur ID: " + modelData.id_capteur
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text {
                            text: "📌 Type: " + modelData.type
                            font.pixelSize: 16
                        }
                        Text {
                            text: "📍 Localisation: " + modelData.localisation
                            font.pixelSize: 16
                        }
                        Text {
                            text: "📝 Description: " + modelData.description
                            font.pixelSize: 14
                        }
                        Text {
                            text: "📊 Dernière valeur: " + modelData.valeur
                            font.pixelSize: 16
                        }
                        Text {
                            text: "📅 Date mesure: " + modelData.date_mesure
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
}
