import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: imageGalleryRoot
    width: parent.width
    height: parent.height

    // Propriétés
    property int rucheId: -1
    property string rucheName: "Ruche"

    // Les droits administrateur
    property bool isAdmin: false

    // L'état de l'importation
    property bool importInProgress: false
    property string statusMessage: ""
    property string statusType: "info"

    ListModel {
        id: imagesModel
    }

    Component.onCompleted: {
        chargerImages();
    }

    function chargerImages() {
        if (rucheId <= 0) {
            console.log("ID de ruche invalide:", rucheId);
            return;
        }

        var images = dManager.getRucheImages(rucheId);

        imagesModel.clear();
        for (var i = 0; i < images.length; i++) {
            imagesModel.append({
                "id": images[i].id_image,
                "chemin": images[i].chemin_fichier,
                "date": images[i].date_capture
            });
        }
        console.log("Images chargées:", imagesModel.count);
    }

    function formatDate(dateString) {
        try {
            var date = new Date(dateString);
            return date.toLocaleString(Qt.locale(), "dd/MM/yyyy HH:mm");
        } catch (e) {
            return dateString;
        }
    }

    function importerImages() {
        if (typeof dManager !== "undefined" && typeof dManager.executeShellCommand === "function") {
            importInProgress = true;
            statusPopup.show("Importation en cours...", "info");
            var command = "/home/pi/sync_images.sh " + rucheId;
            var result = dManager.executeShellCommand(command);
            console.log("Résultat de l'exécution du script:", result);
            var message = "";
            var type = "info";

            // Aucun périphérique n'est détecté
            if (result.includes("Aucun périphérique de stockage externe détecté")) {
                message = "Aucun périphérique de stockage connecté";
                type = "warning";
            }
            // Impossibilité de montage
            else if (result.includes("Impossible de monter le périphérique de stockage")) {
                message = "Impossible de lire le périphérique de stockage";
                type = "error";
            }
            else if (result.startsWith("Succès:") || !result.includes("Erreur:")) {
                if (result.includes("Carte SD montée avec succès")) {
                    // Nombre d'images traitées
                    var match = result.match(/(\d+) nouvelles images traitées/);
                    if (match && match[1]) {
                        var nbImages = parseInt(match[1]);
                        if (nbImages > 0) {
                            message = nbImages + " nouvelle(s) image(s) importée(s) avec succès";
                            type = "success";
                        } else {
                            message = "Toutes les images sont déjà importées";
                            type = "info";
                        }
                    } else {
                        message = "Importation terminée avec succès";
                        type = "success";
                    }
                } else if (result.includes("Aucune carte SD détectée") || result.includes("Aucun périphérique de stockage externe détecté")) {
                    message = "Aucun périphérique de stockage connecté";
                    type = "warning";
                } else if (result.includes("Les dossiers sont déjà synchronisés")) {
                    message = "Toutes les images sont déjà synchronisées";
                    type = "info";
                } else if (result.includes("Synchronisation terminée avec succès")) {
                    message = "Importation terminée avec succès";
                    type = "success";
                } else {
                    message = "Importation terminée";
                    type = "info";
                }
            } else {
                if (result.includes("special device /dev/sda1 does not exist")) {
                    message = "Aucun périphérique de stockage connecté";
                    type = "warning";
                } else {
                    message = "Erreur lors de l'importation";
                    type = "error";
                }
            }

            importInProgress = false;
            // Recharger les images après l'importation
            chargerImages();
            // Afficher le message de statut
            statusPopup.show(message, type);
        } else {
            console.error("La fonction executeShellCommand n'est pas disponible dans dManager");
            statusPopup.show("Erreur: fonction d'importation non disponible", "error");
        }
    }
    function supprimerImage(imageId, cheminImage) {
        console.log("Suppression de l'image:", imageId, "chemin:", cheminImage);

        if (typeof dManager !== "undefined" && typeof dManager.deleteImage === "function") {
            var result = dManager.deleteImage(imageId, cheminImage);
            if (result) {
                chargerImages();
                statusPopup.show("Image supprimée avec succès", "success");
            } else {
                statusPopup.show("Erreur lors de la suppression de l'image", "error");
            }
        } else {
            console.error("La fonction deleteImage n'est pas disponible dans dManager");
            statusPopup.show("Erreur: fonction de suppression non disponible", "error");
        }
    }

    // Interface
    Column {
        anchors.fill: parent
        spacing: 10

        // En-tête avec titre et bouton d'importation
        Rectangle {
            width: parent.width
            height: 40
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Item { // Spacer
                    Layout.fillWidth: true
                }

                Text {
                    text: "Galerie d'images"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Importer"
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 10

                    onClicked: {
                        if (!importInProgress) {
                            importerImages();
                        }
                    }
                    enabled: !importInProgress
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: importInProgress
                        visible: importInProgress
                        width: parent.height * 0.8
                        height: width
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: importInProgress ? 30 : 0
            visible: importInProgress
            color: "#f0f0f0"

            Text {
                anchors.centerIn: parent
                text: statusMessage
                font.italic: true
            }
        }
        Text {
            width: parent.width
            height: imagesModel.count > 0 ? 0 : 30
            visible: imagesModel.count === 0
            text: "Aucune image disponible pour cette ruche"
            horizontalAlignment: Text.AlignHCenter
            font.italic: true
        }

        GridView {
            id: imageGrid
            width: parent.width
            height: parent.height - 50 // Hauteur ajustée pour l'en-tête
            cellWidth: width / 2      // 2 images par ligne
            cellHeight: 180
            clip: true

            model: imagesModel

            delegate: Rectangle {
                width: imageGrid.cellWidth - 10
                height: imageGrid.cellHeight - 10
                color: "white"
                border.color: "#cccccc"
                border.width: 1
                radius: 5

                Column {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    // Image
                    Rectangle {
                        width: parent.width
                        height: parent.height - 30
                        color: "#f0f0f0"
                        Image {
                            anchors.fill: parent
                            source: "file:///var/www/html" + model.chemin
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            BusyIndicator {
                                anchors.centerIn: parent
                                visible: parent.status === Image.Loading
                                running: visible
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: parent.status === Image.Error
                                text: "⚠️"
                                color: "red"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                confirmDeletePopup.imageId = model.id;
                                confirmDeletePopup.imagePath = model.chemin;
                                confirmDeletePopup.open();
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                popupImage.imageSource ="/var/www/html"+ model.chemin;
                                popupImage.imageDate = model.date;
                                popupImage.imageId = model.id;
                                popupImage.open();
                            }
                        }
                    }

                    // Date
                    Text {
                        width: parent.width
                        text: formatDate(model.date)
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    Popup {
        id: popupImage
        width: parent.width * 0.9
        height: parent.height * 0.9
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        // Centre le popup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        property string imageSource: ""
        property string imageDate: ""
        property int imageId: -1

        background: Rectangle {
            color: "black"
            opacity: 0.9
            radius: 5
        }

        contentItem: Item {
            Image {
                anchors.fill: parent
                source: "file://" + popupImage.imageSource
                fillMode: Image.PreserveAspectFit

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: dateText.width + 20
                    height: dateText.height + 10
                    color: "black"
                    opacity: 0.7
                    radius: 5

                    Text {
                        id: dateText
                        anchors.centerIn: parent
                        text: formatDate(popupImage.imageDate)
                        color: "white"
                    }
                }
            }
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                width: 30
                height: 30
                radius: 15
                color: "black"
                opacity: 0.7

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: popupImage.close()
                }
            }
            Rectangle {
                visible: isAdmin
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 10
                width: 30
                height: 30
                radius: 15
                color: "#80FF0000"  // Rouge avec 50% d'opacité

                Text {
                    anchors.centerIn: parent
                    text: "supprimer"
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        popupImage.close();
                        confirmDeletePopup.imageId = popupImage.imageId;
                        confirmDeletePopup.imagePath = popupImage.imageSource.replace("file:///var/www/html", "");
                        confirmDeletePopup.open();
                    }
                }
            }
        }
    }
    Popup {
        id: confirmDeletePopup
        width: 300
        height: 150
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        // Centre le popup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        property int imageId: -1
        property string imagePath: ""

        background: Rectangle {
            color: "white"
            border.color: "#cccccc"
            border.width: 1
            radius: 5
        }

        contentItem: Item {
            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Êtes-vous sûr de vouloir supprimer cette image ?"
                    font.pixelSize: 14
                    width: confirmDeletePopup.width - 40
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "Annuler"
                        width: 100
                        onClicked: confirmDeletePopup.close()
                    }

                    Button {
                        text: "Supprimer"
                        width: 100

                        // Style pour un bouton d'action dangereux
                        background: Rectangle {
                            color: "#f44336"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Appeler la fonction de suppression
                            supprimerImage(confirmDeletePopup.imageId, confirmDeletePopup.imagePath);
                            confirmDeletePopup.close();
                        }
                    }
                }
            }
        }
    }

    // Popup de succès d'importation
    StatusPopup {
        id: statusPopup
    }
}
