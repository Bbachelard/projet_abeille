import QtQuick 2.15
import QtQuick.Controls 2.15
import com.example.ruche 1.0

Item {
    id: root
    width: parent.width
    height: parent.height

    // Propriétés communes
    property var ruchesList: []
    property string backgroundSource: ""
    property int returnDirection: -1
    property bool isAdminView: false

    // Signaux pour les notifications
    signal showSuccess(string message)
    signal showError(string message)

    Component.onCompleted: {
        refreshRuchesList();
    }

    function refreshRuchesList() {
        ruchesList = dManager.getRuchesList();
    }

    // Interface utilisateur
    Image {
        source: backgroundSource
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
            livre.direction = returnDirection;
            livre.pop()
        }
    }

    Column {
        spacing: 20
        anchors.centerIn: parent

        Button {
            text: "Actualiser les ruches"
            width: 250
            height: 50
            onClicked: {
                refreshRuchesList();
            }
        }

        // Bouton d'ajout (visible uniquement en mode admin)
        Button {
            text: "Ajouter une ruche"
            width: 250
            height: 50
            visible: isAdminView
            onClicked: popup.open()
        }

        // Liste des ruches
        Rectangle {
            width: 420
            height: 320
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter

            ListView {
                id: ruchesListView
                spacing: 10
                anchors.fill: parent
                anchors.margins: 10
                model: ruchesList
                delegate: Rectangle {
                    width: parent.width
                    height: 60
                    color: "white"
                    radius: 5
                    border.color: "#cccccc"
                    border.width: 1
                    anchors.margins: 5

                    // Choisir le bon template en fonction du mode d'affichage
                    Item {
                        anchors.fill: parent

                        // Vue utilisateur (contenu simplifié)
                        Column {
                            anchors.centerIn: parent
                            spacing: 5
                            visible: !isAdminView

                            Text {
                                text: "Ruche: " + modelData.name
                                font.bold: true
                                font.pixelSize: 16
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "ID: " + modelData.id_ruche
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 5
                            visible: isAdminView

                            Rectangle {
                                width: parent.width - 110 // Espace pour batterie et bouton
                                height: parent.height
                                color: "transparent"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 5

                                    Text {
                                        text: "Ruche: " + modelData.name
                                        font.bold: true
                                        font.pixelSize: 16
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: "ID: " + modelData.id_ruche
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            Rectangle {
                                width: 60
                                height: parent.height
                                color: "transparent"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    // Icône de batterie
                                    Rectangle {
                                        width: 24
                                        height: 14
                                        color: "transparent"
                                        border.color: "#333333"
                                        border.width: 1
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        // Petite pointe de la batterie
                                        Rectangle {
                                            width: 2
                                            height: 6
                                            color: "#333333"
                                            anchors.left: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        // Niveau de batterie
                                        Rectangle {
                                            width: parent.width * Math.max(0, Math.min(1, modelData.batterie / 100))
                                            height: parent.height - 2
                                            anchors.left: parent.left
                                            anchors.leftMargin: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: getBatteryColor(modelData.batterie)
                                        }
                                    }

                                    Text {
                                        text: Math.round(modelData.batterie) + "%"
                                        font.pixelSize: 12
                                        color: getBatteryColor(modelData.batterie)
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            Rectangle {
                                width: 40
                                height: 40
                                radius: width/2
                                color: deleteMouseArea.pressed ? "#ff6666" : "#ff9999"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "✕"
                                    font.pixelSize: 20
                                    color: "white"
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: deleteMouseArea
                                    anchors.fill: parent
                                    onClicked: {
                                        confirmDeleteDialog.rucheId = modelData.id_ruche;
                                        confirmDeleteDialog.rucheName = modelData.name;
                                        confirmDeleteDialog.open();
                                    }
                                }
                            }
                        }

                        // Zone cliquable pour la navigation (commune aux deux vues)
                        MouseArea {
                            anchors.fill: parent
                            // Ne pas déclencher sur le bouton de suppression en mode admin
                            anchors.rightMargin: isAdminView ? 40 : 0
                            onClicked: navigateToRucheDetails(modelData.id_ruche, modelData.name)
                        }

                        // Indicateur de batterie pour la vue utilisateur
                        Rectangle {
                            width: 70
                            height: parent.height
                            color: "transparent"
                            anchors.right: parent.right
                            visible: !isAdminView

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                // Icône de batterie
                                Rectangle {
                                    width: 24
                                    height: 14
                                    color: "transparent"
                                    border.color: "#333333"
                                    border.width: 1
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    // Petite pointe de la batterie
                                    Rectangle {
                                        width: 2
                                        height: 6
                                        color: "#333333"
                                        anchors.left: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Niveau de batterie
                                    Rectangle {
                                        width: parent.width * Math.max(0, Math.min(1, modelData.batterie / 100))
                                        height: parent.height - 2
                                        anchors.left: parent.left
                                        anchors.leftMargin: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: getBatteryColor(modelData.batterie)
                                    }
                                }

                                Text {
                                    text: Math.round(modelData.batterie) + "%"
                                    font.pixelSize: 12
                                    color: getBatteryColor(modelData.batterie)
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Supprimé : Les composants délégués sont maintenant directement intégrés dans le delegate du ListView

    // Fonction utilitaire pour obtenir la couleur de la batterie
    function getBatteryColor(batteryLevel) {
        if (batteryLevel > 60) return "#4CAF50";  // Vert
        if (batteryLevel > 30) return "#FFC107";  // Jaune
        return "#F44336";  // Rouge
    }

    // Fonction de navigation vers les détails de la ruche
    function navigateToRucheDetails(id, name) {
        console.log("Ruche ID " + id + " sélectionnée");

        try {
            // Récupérer les données de cette ruche
            var rucheData = dManager.getRucheData(id);
            var dataLength = rucheData ? rucheData.length : 0;
            console.log("Données récupérées : ", dataLength);

            // Naviguer vers la page de détails appropriée
            var targetPage = isAdminView ? "P_AData.qml" : "P_UData.qml";
            var direction = isAdminView ? 1 : 2;

            livre.direction = direction;
            livre.push(targetPage, {
                rucheId: id,
                rucheName: name,
                rucheData: rucheData || []
            });
        } catch (e) {
            console.error("Erreur lors de la navigation:", e);

            // Naviguer avec des données minimales en cas d'erreur
            var targetPage = isAdminView ? "P_AData.qml" : "P_UData.qml";
            var direction = isAdminView ? 1 : 2;

            livre.direction = direction;
            livre.push(targetPage, {
                rucheId: id,
                rucheName: name,
                rucheData: []
            });
        }
    }

    // Popup d'ajout de ruche (uniquement pour la vue admin)
    Dialog {
        id: popup
        title: "Ajouter une nouvelle ruche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400
        visible: false

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Column {
            spacing: 15
            width: parent.width

            Text {
                text: "Veuillez saisir les informations de la nouvelle ruche"
                font.pixelSize: 14
                width: parent.width
                wrapMode: Text.WordWrap
            }

            TextField {
                id: rucheName
                width: parent.width
                placeholderText: "Nom de la ruche"
                font.pixelSize: 16
                focus: true
                onPressed: {
                    Qt.inputMethod.show()
                }
            }

            TextField {
                id: mqttAdresse
                width: parent.width
                placeholderText: "Adresse MQTT"
                font.pixelSize: 16
                onPressed: {
                    Qt.inputMethod.show()
                }
            }
        }

        onAccepted: {
            if (rucheName.text.trim() && mqttAdresse.text.trim()) {
                var rucheId = dManager.addOrUpdateRuche(rucheName.text, mqttAdresse.text);
                if (rucheId > 0) {
                    var nouvelleRuche = RucheManager.createRuche(mqttAdresse.text);
                    nouvelleRuche.setId(rucheId);
                    nouvelleRuche.setName(rucheName.text);
                    RucheManager.addRuche(nouvelleRuche);
                    showSuccess("La ruche \"" + rucheName.text + "\" a été ajoutée avec succès.");
                    refreshRuchesList();
                } else {
                    showError("Erreur lors de l'ajout de la ruche.");
                }
            } else {
                showError("Veuillez remplir tous les champs.");
                // Réouvrir le popup
                Qt.callLater(function() {
                    popup.open();
                });
            }
        }
    }

    // Dialogue de confirmation de suppression
    Dialog {
        id: confirmDeleteDialog
        title: "Confirmation de suppression"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        width: 400
        visible: false

        property int rucheId: -1
        property string rucheName: ""

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Êtes-vous sûr de vouloir supprimer la ruche \"" + confirmDeleteDialog.rucheName + "\" (ID: " + confirmDeleteDialog.rucheId + ") ?\n\nToutes les données associées seront également supprimées.\nCette action est irréversible."
            font.pixelSize: 14
        }

        onAccepted: {
            // Exécuter la suppression
            var success = dManager.deleteRuche(confirmDeleteDialog.rucheId);
            if (success) {
                showSuccess("La ruche \"" + confirmDeleteDialog.rucheName + "\" a été supprimée avec succès.");
                refreshRuchesList();
            } else {
                showError("Erreur lors de la suppression de la ruche.");
            }
        }
    }

    // Gérer les notifications
    Rectangle {
        id: successMessage
        visible: false
        color: "#4CAF50"
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        opacity: 0.9
        z: 100

        Text {
            id: successText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
            font.bold: true
            text: ""
        }

        Timer {
            id: successTimer
            interval: 3000
            onTriggered: successMessage.visible = false
        }
    }

    Rectangle {
        id: errorMessage
        visible: false
        color: "#F44336"
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        opacity: 0.9
        z: 100

        Text {
            id: errorText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
            font.bold: true
            text: ""
        }

        Timer {
            id: errorTimer
            interval: 3000
            onTriggered: errorMessage.visible = false
        }
    }

    // Fonctions pour afficher les notifications
    onShowSuccess: function(message) {
        successText.text = message;
        successMessage.visible = true;
        successTimer.restart();
    }

    onShowError: function(message) {
        errorText.text = message;
        errorMessage.visible = true;
        errorTimer.restart();
    }
}
