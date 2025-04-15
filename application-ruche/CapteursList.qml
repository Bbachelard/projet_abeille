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
            var capteurId = _internalCapteursData[i].id_capteur;
            var capteurType = _internalCapteursData[i].type;
            var valeurInfo = "";
            var dateInfo = "";
            var valeurNumerique = 0;
            var alertes = [];
            var hasAlerte = false;
            var texteAlerte = "";
            var alerteType = 0;

            // Récupérer la dernière valeur du capteur si le dataManager est disponible
            if (typeof sensorManager !== 'undefined' && capteurId > 0) {
                var lastValueList = sensorManager.getLastCapteurValue(capteurId, rucheId);

                // Vérifier si la liste contient des données
                if (lastValueList.length > 0) {
                    var lastValueData = lastValueList[0]; // Prendre le premier élément de la liste

                    if (lastValueData.success === true) {
                        valeurNumerique = lastValueData.valeur;
                        valeurInfo = valeurNumerique;

                        // Ajouter l'unité de mesure si disponible
                        if (lastValueData.unite_mesure && lastValueData.unite_mesure !== "") {
                            valeurInfo += " " + lastValueData.unite_mesure;
                        }

                        // Ajouter la date formatée
                        if (lastValueData.date_formatee) {
                            dateInfo = lastValueData.date_formatee;
                        }

                        // Récupérer les alertes pour ce capteur
                        if (typeof alerteManager.getAlertesForCapteur === 'function') {
                            // Appel à la fonction pour récupérer les alertes
                            alertes = alerteManager.getAlertesForCapteur(capteurId, valeurNumerique);



                            // Vérifier s'il y a des alertes
                            hasAlerte = alertes && alertes.length > 0;

                            if (hasAlerte && alertes.length > 0) {
                               try {
                                   texteAlerte = alertes[0].phrase;
                                   alerteType = alertes[0].type || 0;
                                   console.log("Texte d'alerte extrait: " + texteAlerte);
                               } catch (e) {
                                   console.log("Erreur extraction phrase: " + e);
                                   texteAlerte = "Alerte détectée!";
                               }
                           }
                        }
                    }
                }
            }
            // Ajouter au modèle
            capteursModel.append({
                "id": capteurId,
                "type": capteurType,
                "info": "Capteur ID: " + capteurId,
                "valeurInfo": valeurInfo,
                "dateInfo": dateInfo,
                "hasAlerte": hasAlerte,
                "alertes": alertes,
                "texteAlerte": texteAlerte,
                "alerteType": alerteType
            });
        }

        // Vérifier si un élément "Images" existe déjà
        var hasImagesItem = false;
        for (var j = 0; j < capteursModel.count; j++) {
            if (capteursModel.get(j).type.toLowerCase() === "images") {
                hasImagesItem = true;
                break;
            }
        }

        // Ajouter un élément "Images" s'il n'existe pas
        if (!hasImagesItem) {
            capteursModel.append({
                "id": -999, // ID spécial pour le capteur d'images
                "type": "Images",
                "info": "Galerie photos de la ruche",
                "valeurInfo": "",
                "dateInfo": "",
                "hasAlerte": false,
                "alertes": [],
                "texteAlerte": "",
                "alerteType": 4
            });
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10



        Item {
               width: parent.width
               height: 40

                Text {
                    text: "Liste des capteurs"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
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
            height: 80
            color: {
                if (model.hasAlerte) {
                    if (model.alerteType === 0) return "#E8F5E9";      // Vert très clair
                    else if (model.alerteType === 1) return "#FFF8E1"; // Jaune très clair
                    else if (model.alerteType === 2) return "#FFEBEE"; // Rouge très clair
                    else return "#FFEBEE"; // Rouge très clair par défaut si type inconnu
                }
                return "#f0f0f0"; // Couleur par défaut si pas d'alerte
            }
            radius: 5
            border.color:
            {if (model.hasAlerte) {
                  if (model.alerteType === 0) return "#4CAF50";      // Vert
                  else if (model.alerteType === 1) return "#FFC107"; // Jaune/orange
                  else if (model.alerteType === 2) return "#F44336"; // Rouge
                  else return "#F44336"; // Rouge par défaut si type inconnu
              }
              return "#cccccc"; // Gris par défaut
          }
            border.width: model.hasAlerte ? 2 : 1

            ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Column {
                        Layout.fillWidth: true
                        spacing: 5

                        Row {
                            spacing: 5

                            Text {
                                text: model.type
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Rectangle {
                                visible: model.hasAlerte
                                width: 20
                                height: 20
                                radius: 10
                                color: "#F44336"  // Rouge

                                Text {
                                    text: "!"
                                    color: "white"
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Text {
                            text: model.info
                            font.pixelSize: 12
                        }
                    }

                    Column {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 2
                        visible: model.type !== "Images" && model.valeurInfo !== ""

                        // Valeur avec rectangle coloré pour mise en évidence
                        Rectangle {
                            width: valueText.width + 20
                            height: valueText.height + 8
                            color: "#e3f2fd"  // Fond bleu clair
                            radius: 4
                            border.color: "#bbdefb"
                            border.width: 1

                            Text {
                                id: valueText
                                text: model.valeurInfo
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1976d2"  // Bleu plus foncé
                                anchors.centerIn: parent
                            }
                        }

                        // Date de la dernière mesure
                        Text {
                            text: model.dateInfo ? "Relevé le: " + model.dateInfo : ""
                            font.pixelSize: 10
                            font.italic: true
                            color: "#757575"  // Gris pour la date
                            anchors.right: parent.right
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
                Rectangle {
                    Layout.fillWidth: true
                    height: model.hasAlerte ? 20 : 0
                    visible: model.hasAlerte
                    color: {
                        if (model.alerteType === 0) return "#C8E6C9";      // Vert clair
                        else if (model.alerteType === 1) return "#FFF9C4"; // Jaune clair
                        else if (model.alerteType === 2) return "#FFCDD2"; // Rouge clair
                        return "#FFCDD2"; // Rouge clair par défaut
                    }
                    radius: 4

                    Text {
                        id: alertText
                        // Texte fixe pour test
                        text: model.texteAlerte
                        font.pixelSize: 12
                        font.bold: true
                        color:  {
                            if (model.alerteType === 0) return "#2E7D32";      // Vert foncé
                            else if (model.alerteType === 1) return "#F57F17"; // Orange foncé
                            else if (model.alerteType === 2) return "#D32F2F"; // Rouge foncé
                            return "#D32F2F"; // Rouge foncé par défaut
                        }
                        anchors.fill: parent
                        anchors.margins: 5
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WordWrap
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

