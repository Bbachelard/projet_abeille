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
                    Button {
                        visible: isViewA && model.type === "Images" // Afficher uniquement pour les images
                        text: "..."
                        width: 40
                        height: 40

                        background: Rectangle {
                            color: parent.pressed ? "#4CAF50" : "#6200EE"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }

                        onClicked: {
                            imagesPopup.open()
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




    Popup {
        id: imagesPopup
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            radius: 10
            color: "white"
            border.color: "#cccccc"
            border.width: 1
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                width: parent.width
                text: "Ruche " + rucheName
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                width: parent.width
                height: 20
            }

            ComboBox {
                id: resolutionComboBox
                width: parent.width
                model: ["320x240", "640x480", "800x600"]

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    border.color: resolutionComboBox.pressed ? "#2196F3" : "#3F51B5"
                    border.width: 1
                    radius: 5
                }

                onCurrentTextChanged: {
                    if (resolutionComboBox.currentText) {
                        console.log("Résolution sélectionnée: " + resolutionComboBox.currentText)
                    }
                }
            }

            Button {
                width: parent.width
                height: 50
                text: "Définir résolution"

                background: Rectangle {
                    color: parent.pressed ? "#2196F3" : "#3F51B5"
                    radius: 5
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    var resolution = resolutionComboBox.currentText
                    if (resolution) {
                        var message = "resolution:" + resolution
                        mqttHandler.sendMqttMessage(rucheName, message)
                        imagesPopup.close()
                        statusMessage.show("Configuration de résolution " + resolution + " envoyée", "info")
                    }
                }
            }

            Item {
                width: parent.width
                height: 20
                Layout.fillHeight: true
            }

            Button {
                width: parent.width
                height: 50
                text: "Fermer"

                background: Rectangle {
                    color: parent.pressed ? "#BDBDBD" : "#9E9E9E"
                    radius: 5
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    imagesPopup.close()
                }
            }
        }
    }
}

