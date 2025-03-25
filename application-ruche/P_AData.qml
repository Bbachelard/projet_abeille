import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.example.ruche 1.0

Item {
    id: root
    width: parent.width
    height: parent.height

    property int rucheId: -1
    property string rucheName: "Ruche"
    property var rucheData: []

    RucheView {
        id: rucheView
        anchors.fill: parent

        backgroundSource: "qrc:/fond5.png"
        returnDirection: 1
        isViewA: true

        rucheId: root.rucheId
        rucheName: root.rucheName
        rucheData: root.rucheData

        onCapteurDeletedRequest: function(capteurId) {
            confirmDeleteCapteurDialog.capteurId = capteurId;
            confirmDeleteCapteurDialog.open();
        }

        onCapteurAddRequest: function() {
            addCapteurDialog.rucheId = rucheId;
            addCapteurDialog.open();
        }
    }

    // Popup de confirmation de suppression de capteur
    Popup {
        id: confirmDeleteCapteurDialog
        width: 300
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        z: 100

        property int capteurId: -1
        property string capteurType: "ce capteur"
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle {
            width: parent.width
            height: parent.height
            color: "lightgray"
            border.color: "gray"

            Column {
                anchors.centerIn: parent
                spacing: 10
                width: parent.width - 20

                Text {
                    text: "Confirmation de suppression"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "Êtes-vous sûr de vouloir supprimer ce capteur ?\n\nToutes les données associées seront également supprimées."
                    font.pixelSize: 14
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "Supprimer"
                        width: 120
                        height: 40

                        onClicked: {
                            var success = dManager.deleteCapteur(confirmDeleteCapteurDialog.capteurId);
                            if (capteurId > 0) {
                                rucheView.refreshData();
                                confirmDeleteCapteurDialog.close();
                            }
                        }
                    }
                    Button {
                        text: "Annuler"
                        width: 120
                        height: 40
                        onClicked: confirmDeleteCapteurDialog.close()
                    }
                }
            }
        }
    }
    // Popup d'ajout de capteur
    Popup {
        id: addCapteurDialog
        width: 300
        height: 320
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        z: 100

        property int rucheId: -1

        // Centrer le popup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle {
            width: parent.width
            height: parent.height
            color: "lightgray"
            border.color: "gray"

            Column {
                anchors.centerIn: parent
                spacing: 15
                width: parent.width - 40

                Text {
                    text: "Ajouter un nouveau capteur"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 18
                    font.bold: true
                }

                // Champ de texte pour le type de capteur
                TextField {
                    id: capteurTypeInput
                    width: parent.width
                    placeholderText: "Type de capteur"
                    font.pixelSize: 14
                    onPressed: {
                        Qt.inputMethod.show()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Types courants:"
                        font.pixelSize: 12
                        color: "#666666"
                    }

                    Flow {
                        width: parent.width
                        spacing: 5

                        Repeater {
                            model: ["Température", "Humidité", "Poids", "Pression", "Luminosité", "CO2", "Son"]

                            delegate: Rectangle {
                                height: 26
                                width: suggestionText.width + 20
                                color: "#e0e0e0"
                                radius: 13

                                Text {
                                    id: suggestionText
                                    text: modelData
                                    anchors.centerIn: parent
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        capteurTypeInput.text = modelData;
                                    }
                                }
                            }
                        }
                    }
                }

                TextField {
                    id: capteurLocalisation
                    width: parent.width
                    placeholderText: "Localisation (optionnel)"
                    font.pixelSize: 14
                    onPressed: {
                        Qt.inputMethod.show()
                    }
                }

                TextField {
                    id: capteurDescription
                    width: parent.width
                    placeholderText: "Description (optionnel)"
                    font.pixelSize: 14
                    onPressed: {
                        Qt.inputMethod.show()
                    }
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "Ajouter"
                        width: 120
                        height: 40

                        onClicked: {
                            if (addCapteurDialog.rucheId > 0) {
                                // Vérifier que le type de capteur a été saisi
                                if (capteurTypeInput.text.trim() === "") {
                                    // Afficher un message d'erreur
                                    errorMessage.text = "Veuillez saisir un type de capteur.";
                                    errorMessage.visible = true;
                                    errorTimer.restart();
                                    return;
                                }

                                // Ajouter le capteur à la base de données
                                var capteurId = dManager.addCapteur(
                                    addCapteurDialog.rucheId,
                                    capteurTypeInput.text.trim(),
                                    capteurLocalisation.text,
                                    capteurDescription.text
                                );

                                if (capteurId > 0) {
                                    rucheView.refreshData();

                                    // Afficher un message de succès
                                    successMessage.text = "Capteur ajouté avec succès!";
                                    successMessage.visible = true;
                                    successTimer.restart();

                                    // Fermer le popup
                                    addCapteurDialog.close();

                                    // Réinitialiser les champs
                                    capteurTypeInput.text = "";
                                    capteurLocalisation.text = "";
                                    capteurDescription.text = "";
                                } else {
                                    // Afficher un message d'erreur
                                    errorMessage.text = "Erreur lors de l'ajout du capteur.";
                                    errorMessage.visible = true;
                                    errorTimer.restart();
                                }
                            } else {
                                // Afficher un message d'erreur
                                errorMessage.text = "ID de ruche invalide.";
                                errorMessage.visible = true;
                                errorTimer.restart();
                            }
                        }
                    }

                    Button {
                        text: "Annuler"
                        width: 120
                        height: 40
                        onClicked: addCapteurDialog.close()
                    }
                }
            }
        }
    }

    // Composants pour les messages de notification
    Rectangle {
        id: successMessage
        visible: false
        color: "#4CAF50"
        height: 50
        width: parent.width
        anchors.bottom: parent.bottom
        opacity: 0.9
        z: 101 // Au-dessus des popups

        Text {
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
        z: 101 // Au-dessus des popups

        Text {
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

    Component.onCompleted: {
        console.log("P_AData onCompleted - rucheId:", root.rucheId); // Ajoutez ce log
        rucheView.rucheId = root.rucheId;
        rucheView.rucheName = root.rucheName;
        rucheView.rucheData = root.rucheData;
    }
}
