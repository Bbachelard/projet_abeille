import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: capteursListRoot
    width: parent.width
    height: parent.height

    // Signal émis lorsqu'un capteur est sélectionné
    signal capteurSelected(int capteurId)

    // Signal pour supprimer un capteur
    signal capteurDeleted(int capteurId)

    // Signal pour ajouter un capteur
    signal addCapteurRequested()

    // Propriété pour savoir si on est dans la vue A (pour afficher les boutons)
    property bool isViewA: false

    // Propriété pour stocker les données des capteurs (en privé)
    property var _internalCapteursData: []

    // Fonction pour mettre à jour les capteurs (au lieu d'un binding direct)
    function updateCapteurs(newCapteursData) {
        // Utiliser une copie pour éviter les bindings
        _internalCapteursData = JSON.parse(JSON.stringify(newCapteursData));

        // Mettre à jour le modèle
        capteursModel.clear();
        for (var i = 0; i < _internalCapteursData.length; i++) {
            capteursModel.append({
                "id": _internalCapteursData[i].id_capteur,
                "type": _internalCapteursData[i].type,
                "info": "Capteur ID: " + _internalCapteursData[i].id_capteur
            });
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width
            height: 40
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Liste des capteurs"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            // Bouton d'ajout de capteur (uniquement visible dans la vue A)
            Rectangle {
                id: addButton
                width: 30
                height: 30
                radius: width/2
                color: addMouseArea.pressed ? "#4CAF50" : "#66BB6A"
                visible: isViewA
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "+"
                    font.pixelSize: 20
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: addMouseArea
                    anchors.fill: parent
                    onClicked: {
                        addCapteurRequested();
                    }
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

                    // Contenu du capteur
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

                    // Bouton de suppression (uniquement visible dans la vue A)
                    Rectangle {
                        id: deleteButton
                        width: 30
                        height: 30
                        radius: width/2
                        color: delBtnMouseArea.pressed ? "#ff6666" : "#ff9999"
                        visible: isViewA
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                        Text {
                            text: "✕"
                            font.pixelSize: 16
                            color: "white"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: delBtnMouseArea
                            anchors.fill: parent
                            onClicked: {
                                // Émettre le signal de suppression avec l'ID du capteur
                                capteurDeleted(model.id);
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: isViewA ? 50 : 0 // Éviter le chevauchement avec le bouton de suppression
                    onClicked: {
                        capteurSelected(model.id);
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
