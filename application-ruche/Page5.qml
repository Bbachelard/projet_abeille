import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

Item {
    width: parent.width
    height: parent.height

    property var ruche
    property var rucheData: rucheData || []
    property var capteursData: []

    property int capteurSelectionne:1
    property var graphData: []

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

    Text {
        text: "Ruche ID: " + ruche.getId()
        font.pixelSize: 36
    }
    Column {
        width: parent.width
        spacing: 10
        anchors.top: parent.top
        anchors.topMargin: 70

        Row {
            spacing: 20
            Button {
            text: "Capteur est dernière donnée"
            onClicked: {
                capteursData = dManager.getRucheData();
                }
            }
            Button {
                text: "tableaux données"
                onClicked: {
                    tablePopup.open()
                    graphData = dManager.getAllRucheData;
                }
            }
            ComboBox {
               width: 200
               model: capteursData
               textRole: "nom_capteur"
               delegate: ItemDelegate {
                       width: parent.width
                       text: modelData.type
                   }

                   onActivated: (index) => {
                       capteurSelectionne = capteursData[index].id_capteur;
                       console.log("Capteur sélectionné:", capteursData[index].type);
                   }
            }
        }



        ListView {
            width: parent.width
            height: 500
            model: capteursData
            spacing: 15
            anchors.top: parent.top
            anchors.topMargin: 100

            delegate:Rectangle {
                width: 530
                height: 150
                anchors.leftMargin: 100
                color: "#eeeeee"
                radius: 10
                border.color: "#aaaaaa"
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    spacing: 5

                    Text {
                        text: "Capteur ID: " + modelData.id_capteur
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Text {
                        text: "Type: " + modelData.type
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Localisation: " + modelData.localisation
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Description: " + modelData.description
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Dernière valeur: " + modelData.valeur
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Date mesure: " + modelData.date_mesure
                        font.pixelSize: 14
                    }
                }
            }
        }
    }

    Popup {
        id: tablePopup
        width: 600
        height: 400
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#ffffffdd"
            radius: 10
            border.color: "#aaaaaa"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 10
            Text {
                text: "Tableau du capteur"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            ListModel {
                id: dataModel
            }
            // Conteneur scrollable pour la table
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: listView.contentHeight
                clip: true

                Column {
                    width: parent.width
                    // En-tête de la table
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Rectangle { width: 80; height: 40; color: "#d3d3d3"; border.color: "#999"
                            Text { text: "ID"; anchors.centerIn: parent; font.bold: true }
                        }
                        Rectangle { width: 120; height: 40; color: "#d3d3d3"; border.color: "#999"
                            Text { text: "Type"; anchors.centerIn: parent; font.bold: true }
                        }
                        Rectangle { width: 100; height: 40; color: "#d3d3d3"; border.color: "#999"
                            Text { text: "Valeur"; anchors.centerIn: parent; font.bold: true }
                        }
                        Rectangle { width: 180; height: 40; color: "#d3d3d3"; border.color: "#999"
                            Text { text: "Date Mesure"; anchors.centerIn: parent; font.bold: true }
                        }
                    }
                    // Contenu de la table
                    ListView {
                        id: listView
                        width: parent.width
                        height: 250
                        model: dataModel
                        clip: true
                        delegate: RowLayout {
                            width: ListView.view.width
                            height: 40
                            spacing: 5
                            Rectangle { width: 80; height: 40; color: index % 2 === 0 ? "#f9f9f9" : "#ffffff"; border.color: "#999"
                                Text { text: model.id_capteur; anchors.centerIn: parent }
                            }
                            Rectangle { width: 120; height: 40; color: index % 2 === 0 ? "#f9f9f9" : "#ffffff"; border.color: "#999"
                                Text { text: model.type; anchors.centerIn: parent }
                            }
                            Rectangle { width: 100; height: 40; color: index % 2 === 0 ? "#f9f9f9" : "#ffffff"; border.color: "#999"
                                Text { text: model.valeur; anchors.centerIn: parent }
                            }
                            Rectangle { width: 180; height: 40; color: index % 2 === 0 ? "#f9f9f9" : "#ffffff"; border.color: "#999"
                                Text { text: model.date_mesure; anchors.centerIn: parent }
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Button {
                    text: "Charger les données"
                    onClicked: {
                        var allData = dManager.getAllRucheData();
                        dataModel.clear();
                        for (var i = 0; i < allData.length; i++) {
                            dataModel.append(allData[i]);
                        }
                    }
                }
                Button {
                    text: "Fermer"
                    onClicked: tablePopup.close()
                }
            }
        }
    }
}
