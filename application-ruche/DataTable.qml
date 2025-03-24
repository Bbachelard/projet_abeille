import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: dataTableRoot
    width: parent.width
    height: parent.height

    // Propriétés exposées
    property var tableData: []
    property string capteurType: ""

    // Propriétés internes
    property string sortColumn: "date_mesure"
    property bool sortAscending: false
    property string filterValue: ""

    // Fonction pour mettre à jour le modèle de données
    function updateTableModel() {
        // Vider le modèle
        tableModel.clear();

        // Si aucune donnée, sortir
        if (!tableData || tableData.length === 0) return;

        // Copier les données pour ne pas modifier l'original
        var dataCopy = [];
        for (var i = 0; i < tableData.length; i++) {
            dataCopy.push({
                typeCapteur: capteurType,
                valeur: tableData[i].valeur,
                date_mesure: tableData[i].date_mesure
            });
        }

        // Appliquer le filtre
        if (filterValue) {
            dataCopy = dataCopy.filter(function(item) {
                return item.typeCapteur.toString().toLowerCase().includes(filterValue.toLowerCase()) ||
                       item.valeur.toString().includes(filterValue) ||
                       item.date_mesure.toString().includes(filterValue);
            });
        }

        // Trier les données
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

            // Gérer les valeurs non définies
            if (aValue === undefined) aValue = "";
            if (bValue === undefined) bValue = "";

            // Trier
            if (aValue < bValue) return sortAscending ? -1 : 1;
            if (aValue > bValue) return sortAscending ? 1 : -1;
            return 0;
        });

        // Ajouter au modèle
        for (var j = 0; j < dataCopy.length; j++) {
            tableModel.append(dataCopy[j]);
        }
    }

    // Fonction pour trier par colonne
    function sortByColumn(column) {
        if (sortColumn === column) {
            // Inverser l'ordre si on clique sur la même colonne
            sortAscending = !sortAscending;
        } else {
            // Nouvelle colonne, ordre ascendant par défaut
            sortColumn = column;
            sortAscending = true;
        }

        // Mettre à jour le modèle
        updateTableModel();
    }

    Column {
        anchors.fill: parent
        spacing: 10

        // Titre du tableau
        Text {
            text: "Données du capteur: " + capteurType
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            TextField {
                id: filterField
                width: 150
                placeholderText: "Rechercher..."
                onTextChanged: {
                    filterValue = text;
                    updateTableModel();
                }
            }

            ComboBox {
                id: sortOrderCombo
                width: 250
                model: ["Plus récent", "Plus ancien", "Valeurs croissantes", "Valeurs décroissantes"]
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                        case 0: // Plus récent d'abord
                            sortColumn = "date_mesure";
                            sortAscending = false;
                            break;
                        case 1: // Plus ancien d'abord
                            sortColumn = "date_mesure";
                            sortAscending = true;
                            break;
                        case 2: // Valeurs croissantes
                            sortColumn = "valeur";
                            sortAscending = true;
                            break;
                        case 3: // Valeurs décroissantes
                            sortColumn = "valeur";
                            sortAscending = false;
                            break;
                    }
                    updateTableModel();
                }
            }

            Button {
                text: "Actualiser"
                onClicked: updateTableModel()
            }
        }

        // En-tête du tableau
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
                    width: parent.width * 0.2
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "Valeur" + (sortColumn === "valeur" ? (sortAscending ? " ▲" : " ▼") : "")
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
                    width: parent.width * 0.5
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

        // Liste des données
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
                            text: valeur.toFixed(2)
                            width: parent.width * 0.2
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: date_mesure
                            width: parent.width * 0.5
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Texte si aucune donnée
            Text {
                anchors.centerIn: parent
                text: "Aucune donnée disponible"
                font.pixelSize: 16
                visible: tableModel.count === 0
            }
        }

        // Information sur le nombre d'enregistrements
        Text {
            text: tableModel.count + " enregistrement(s)"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
