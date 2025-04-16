import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: dataTableRoot
    width: parent.width
    height: parent.height

    property var tableData: []
    property string capteurType: ""
    property string uniteMesure: ""
    property real seuilMiel: 0
    property string sortColumn: "date_mesure"
    property bool sortAscending: false
    property string filterValue: ""

    function updateTableModel() {
        tableModel.clear();
        if (!tableData || tableData.length === 0) return;
        var dataCopy = [];
        for (var i = 0; i < tableData.length; i++) {
                var seuil = 0;
                if (tableData[i].seuil_miel !== undefined) {
                    seuil = tableData[i].seuil_miel;
                }
                dataCopy.push({
                    typeCapteur: capteurType,
                    valeur: tableData[i].valeur,
                    date_mesure: tableData[i].date_mesure,
                    unite_mesure: tableData[i].unite_mesure || uniteMesure,
                    seuil_miel: seuil
                });
        }

        if (filterValue) {
            dataCopy = dataCopy.filter(function(item) {
                return item.typeCapteur.toString().toLowerCase().includes(filterValue.toLowerCase()) ||
                       item.valeur.toString().includes(filterValue) ||
                       item.date_mesure.toString().includes(filterValue) ||
                       (item.unite_mesure && item.unite_mesure.toString().toLowerCase().includes(filterValue.toLowerCase()));
            });
        }

        dataCopy.sort(function(a, b) {
            var aValue, bValue;

            if (sortColumn === "valeur") {
                aValue = parseFloat(a.valeur);
                bValue = parseFloat(b.valeur);
            } else if (sortColumn === "date_mesure") {
                aValue = new Date(a.date_mesure).getTime();
                bValue = new Date(b.date_mesure).getTime();
            } else if (sortColumn === "typeCapteur") {
                aValue = a.typeCapteur.toLowerCase();
                bValue = b.typeCapteur.toLowerCase();
            } else {
                aValue = a[sortColumn];
                bValue = b[sortColumn];
            }

            if (aValue === undefined) aValue = "";
            if (bValue === undefined) bValue = "";

            // Trier
            if (aValue < bValue) return sortAscending ? -1 : 1;
            if (aValue > bValue) return sortAscending ? 1 : -1;
            return 0;
        });

        for (var j = 0; j < dataCopy.length; j++) {
            tableModel.append(dataCopy[j]);
        }
    }

    function sortByColumn(column) {
        if (sortColumn === column) {
            sortAscending = !sortAscending;
        } else {
            sortColumn = column;
            sortAscending = true;
        }
        updateTableModel();
    }

    Column {
        anchors.fill: parent
        spacing: 10
        Text {
            text: "Données du capteur: " + capteurType + (uniteMesure ? " (" + uniteMesure + ")" : "")
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                id: sortOrderCombo
                width: 250
                model: ["Plus récent", "Plus ancien", "Valeurs croissantes", "Valeurs décroissantes"]
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                        case 0:
                            sortColumn = "date_mesure";
                            sortAscending = false;
                            break;
                        case 1:
                            sortColumn = "date_mesure";
                            sortAscending = true;
                            break;
                        case 2:
                            sortColumn = "valeur";
                            sortAscending = true;
                            break;
                        case 3:
                            sortColumn = "valeur";
                            sortAscending = false;
                            break;
                    }
                    updateTableModel();
                }
            }
        }

        Rectangle {
            width: parent.width - 40
            height: 40
            color: "#d3d3d3"
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                anchors.fill: parent
                anchors.margins: 5

                Rectangle {
                    width: parent.width * 0.3
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "Type"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: sortByColumn("typeCapteur")
                    }
                }

                Rectangle {
                    width: parent.width * 0.3
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: {
                                var headerText = "Valeur";
                                // Si c'est un capteur de masse, ajouter le texte du seuil
                                if (capteurType.toLowerCase().includes("masse")) {
                                    headerText = "Valeur / Seuil";
                                }
                                // Ajouter l'indicateur de tri si nécessaire
                                if (sortColumn === "valeur") {
                                    headerText += (sortAscending ? " ▲" : " ▼");
                                }
                                return headerText;
                            }
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: sortByColumn("valeur")
                    }
                }

                Rectangle {
                    width: parent.width * 0.4
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "Date et heure" + (sortColumn === "date_mesure" ? (sortAscending ? " ▲" : " ▼") : "")
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: sortByColumn("date_mesure")
                    }
                }
            }
        }

        Rectangle {
            width: parent.width - 40
            height: parent.height - 140
            border.color: "#cccccc"
            border.width: 1
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter

            ListModel {
                id: tableModel
            }

            Component.onCompleted: {
                updateTableModel();
            }

            ListView {
                id: tableView
                anchors.fill: parent
                anchors.margins: 5
                model: tableModel
                clip: true

                ScrollBar.vertical: ScrollBar {
                    active: true
                }

                delegate: Rectangle {
                    width: tableView.width
                    height: 40
                    color: index % 2 === 0 ? "#f5f5f5" : "white"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 5

                        Text {
                            text: typeCapteur
                            width: parent.width * 0.3
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: {
                                var valeurFormatee = valeur.toFixed(2);
                                if (typeCapteur.toLowerCase().includes("masse") && model.seuil_miel !== undefined && model.seuil_miel > 0) {
                                    valeurFormatee += " / " + model.seuil_miel.toFixed(2);
                                }
                                if (unite_mesure) {
                                    valeurFormatee += " " + unite_mesure;
                                }
                                return valeurFormatee;
                            }
                            width: parent.width * 0.3
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: date_mesure
                            width: parent.width * 0.4
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                text: "Aucune donnée disponible"
                font.pixelSize: 16
                visible: tableModel.count === 0
            }
        }

        Text {
            text: tableModel.count + " enregistrement(s)"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
