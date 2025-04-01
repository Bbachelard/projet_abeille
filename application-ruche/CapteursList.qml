import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: capteursListRoot
    width: parent.width
    height: parent.height

    signal capteurSelected(int capteurId)
    signal showImagesRequested(int rucheId)

    property int rucheId: -1
    property bool isViewA: false
    property var _internalCapteursData: []

    function updateCapteurs(newCapteursData) {
        _internalCapteursData = JSON.parse(JSON.stringify(newCapteursData));
        capteursModel.clear();
        for (var i = 0; i < _internalCapteursData.length; i++) {
            capteursModel.append({
                "id": _internalCapteursData[i].id_capteur,
                "type": _internalCapteursData[i].type,
                "info": "Capteur ID: " + _internalCapteursData[i].id_capteur
            });
        }
        var hasImagesItem = false;
        for (var j = 0; j < capteursModel.count; j++) {
            if (capteursModel.get(j).type.toLowerCase() === "images") {
                hasImagesItem = true;
                break;
            }
        }
        if (!hasImagesItem) {
            capteursModel.append({
                "id": -999, // ID spécial pour le capteur d'images
                "type": "Images",
                "info": "Galerie photos de la ruche"
            });
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10
        Item {
               width: parent.width
               height: 40
            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15
                Text {
                    text: "Liste des capteurs"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        ListView {
            id: capteursListView
            width: parent.width - 40
            height: parent.height - 60
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            spacing: 5

            model: ListModel {
                id: capteursModel
            }

            delegate: Rectangle {
                width: capteursListView.width
                height: 60
                color: "#f0f0f0"
                radius: 5
                border.color: "#cccccc"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Column {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: model.type
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            text: model.info
                            font.pixelSize: 12
                        }
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: isViewA ? 50 : 0
                    onClicked: {
                        if (model.type === "Images") {
                            showImagesRequested(rucheId);
                        } else {
                            capteurSelected(model.id);
                        }
                    }
                }
            }
            ScrollBar.vertical: ScrollBar {}
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: capteursModel.count + " capteur(s) disponible(s)"
            font.pixelSize: 12
            visible: capteursModel.count > 0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Aucun capteur disponible"
            font.pixelSize: 16
            visible: capteursModel.count === 0
        }
    }
}
