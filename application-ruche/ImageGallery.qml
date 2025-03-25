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

    // Fonction pour formater les dates
    function formatDate(dateString) {
        try {
            var date = new Date(dateString);
            return date.toLocaleString(Qt.locale(), "dd/MM/yyyy HH:mm");
        } catch (e) {
            return dateString;
        }
    }

    // Interface
    Column {
        anchors.fill: parent
        spacing: 10
        Text {
            text: "Galerie d'images "
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
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
            height: parent.height - 40 // Hauteur moins le titre
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
                            source: "file://" + model.chemin
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

                        // Clic pour agrandir
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                popupImage.imageSource = model.chemin;
                                popupImage.imageDate = model.date;
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

    // Popup pour l'image agrandie
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

        // Propriétés
        property string imageSource: ""
        property string imageDate: ""

        // Arrière-plan
        background: Rectangle {
            color: "black"
            opacity: 0.9
            radius: 5
        }

        // Contenu
        contentItem: Item {
            // Image
            Image {
                anchors.fill: parent
                source: "file://" + popupImage.imageSource
                fillMode: Image.PreserveAspectFit

                // Date
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

            // Bouton fermer
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
        }
    }
}
