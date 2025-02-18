import QtQuick 2.15
import QtQuick.Controls 2.15
import com.example.ruche 1.0

Item {
    width: parent.width
    height: parent.height
    Image {
        source: "qrc:/fond4.png"
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
            livre.direction = 2;
            livre.pop()
        }
    }
    Column {
           spacing: 20
           anchors.centerIn: parent
           Button {
               text: "Sauvegarder BDD"
               width: 250
               height: 50
               onClicked: {
                   console.log("Sauvegarde en cours...");
                   dExport.saveData(1, 23.5, "2025-01-24 18:24:26");
                   console.log("Sauvegarde effectuée.");
               }
           }

            Button {
                text: "Ajouter une ruche"
                width: 250
                height: 50
                onClicked: {
                    var nouvelleRuche = RucheManager.createTestRuche();
                    ruchesList.push(nouvelleRuche);
               }
           }

           // Liste des ruches
            Rectangle {
                width: 400
                height: 300
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter

                ListView {
                    anchors.fill: parent
                    anchors.margins: 10
                    model: RucheManager.ruches // Utilisation du modèle correct
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: "transparent"
                        anchors.margins: 5

                        Button {
                            text: "Ruche ID: " + modelData.getId()
                            anchors.centerIn: parent
                            font.bold: true
                            font.pixelSize: 16
                            background: Rectangle {
                                color: "white"
                                radius: 5
                            }
                            onClicked: {
                                console.log("Ruche ID " + modelData.getId() + " sélectionnée");
                                var rucheData = modelData.getDataList();
                                console.log("Données récupérées : ", rucheData);
                                livre.direction = 1;
                                livre.push("Page5.qml", { ruche: modelData, rucheData: rucheData });
                            }
                        }
                    }
                }
               }
           }
    }

