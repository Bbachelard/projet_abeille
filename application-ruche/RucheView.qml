import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.example.ruche 1.0

Item {
    id: root
    width: parent.width
    height: parent.height

    // Propriétés pour les données de la ruche
    property int rucheId: -1
    property string rucheName: "Ruche"
    property var ruche: null
    property var rucheData: []
    property var capteursData: []

    property int capteurSelectionne: 1
    property var graphData: []
    property string selectedCapteurType: ""
    property bool showAllCapteurs: false
    property double rucheBattery: 0

    // Propriétés personnalisables
    property string backgroundSource: ""
    property int returnDirection: 1
    property bool isViewA: false

    // Signaux pour la gestion des capteurs
    signal capteurDeletedRequest(int capteurId)
    signal capteurAddRequest()

    // Création du gestionnaire de données
    DataManager {
        id: dataManager

        // Gestionnaire du signal de données chargées
        onDataLoaded: function(data) {
            // Utiliser une copie pour éviter les bindings
            capteursData = JSON.parse(JSON.stringify(data));
            // Mise à jour du ComboBox des capteurs
            updateCapteurComboBox();
        }

        // Gestionnaire du signal de données de graphique chargées
        onChartDataLoaded: function(data, minDate, maxDate, capteurType, isMultiple) {
            // Utiliser une copie pour éviter les bindings
            graphData = JSON.parse(JSON.stringify(data));
            selectedCapteurType = capteurType;

            // Mise à jour des composants d'interface
            updateGraphView(data, minDate, maxDate, capteurType, isMultiple);
            updateDataTable(data, capteurType);
        }
    }

    Component.onCompleted: {
        // Initialiser le gestionnaire de données
        dataManager.initialize(dManager);

        if (rucheData && rucheData.length > 0) {
            // Utiliser une copie profonde pour éviter les bindings
            capteursData = JSON.parse(JSON.stringify(rucheData));
            updateCapteurComboBox();
            if (capteursData.length > 0 && capteurSelectionne > 0) {
                refreshChartData();
            }
        } else {
            refreshData();
        }
        loadRucheBattery();
    }

    // Fonctions d'interface utilisateur
    function refreshData() {
        if (rucheId > 0) {
            var data = dataManager.loadRucheData(rucheId);
            // Ne pas assigner directement pour éviter un binding
            if (data && data.length > 0) {
                // Utiliser une copie pour éviter les bindings
                capteursData = JSON.parse(JSON.stringify(data));
            }
        }
    }

    function refreshChartData() {
        if (rucheId > 0) {
            // Passer une copie des données pour éviter les bindings
            var capteursCopy = JSON.parse(JSON.stringify(capteursData));
            dataManager.loadChartData(rucheId, capteurSelectionne, capteursCopy, showAllCapteurs);
        }
    }

    function updateCapteurComboBox() {
        capteurComboModel.clear();
        capteurComboModel.append({"name": "Tous", "id": -1});
        if (capteursData && capteursData.length > 0) {
            for (var i = 0; i < capteursData.length; i++) {
                capteurComboModel.append({
                    "name": capteursData[i].type,
                    "id": capteursData[i].id_capteur
                });
            }
        }
    }

    function updateGraphView(data, minDate, maxDate, capteurType, isMultiple) {
        // Passer une copie des données pour éviter les bindings
        graphView.chartData = JSON.parse(JSON.stringify(data));
        graphView.chartTitle = isMultiple ? "Évolution de tous les capteurs" : ("Évolution des " + capteurType);
        graphView.capteurType = capteurType;
        graphView.showAllCapteurs = isMultiple;
        graphView.minDate = minDate;
        graphView.maxDate = maxDate;
        graphView.initGraphValues();
    }

    function updateDataTable(data, capteurType) {
        // Passer une copie des données pour éviter les bindings
        dataTable.tableData = JSON.parse(JSON.stringify(data));
        dataTable.capteurType = capteurType;
        dataTable.updateTableModel();
    }

    function loadRucheBattery() {
        if (rucheId > 0) {
            var ruches = dManager.getRuchesList();
            for (var i = 0; i < ruches.length; i++) {
                if (ruches[i].id_ruche === rucheId) {
                    rucheBattery = ruches[i].batterie;
                    break;
                }
            }
        }
    }

    Connections {
        target: RucheManager
        function onBatteryUpdated(rucheId, batteryValue) {
            if (rucheId === root.rucheId) {
                rucheBattery = batteryValue;
            }
        }
    }

    // Interface utilisateur
    Image {
        source: backgroundSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        z: -1
    }

    Rectangle {
        id: batteryIndicator
        width: 80
        height: 40
        color: "transparent"
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
        }

        Row {
            anchors.centerIn: parent
            spacing: 5

            // Icône de batterie
            Rectangle {
                width: 30
                height: 20
                color: "transparent"
                border.color: "#333333"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                // Petite pointe de la batterie
                Rectangle {
                    width: 2
                    height: 10
                    color: "#333333"
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Niveau de batterie
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, rucheBattery / 100))
                    height: parent.height - 2
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter

                    // Couleur en fonction du niveau de batterie
                    color: {
                        if (rucheBattery > 60) return "#4CAF50";  // Vert
                        if (rucheBattery > 30) return "#FFC107";  // Jaune
                        return "#F44336";  // Rouge
                    }
                }
            }

            // Texte du pourcentage
            Text {
                text: Math.round(rucheBattery) + "%"
                font.pixelSize: 14
                font.bold: true
                color: {
                    if (rucheBattery > 60) return "#4CAF50";  // Vert
                    if (rucheBattery > 30) return "#FFC107";  // Jaune
                    return "#F44336";  // Rouge
                }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Button {
        text: "retour"
        width: 100
        height: 40
        anchors {
            top: parent.top
            right: parent.right
            margins: 10
        }
        onClicked: {
            livre.direction = returnDirection;
            livre.pop()
        }
    }

    Text {
        id: rucheTitle
        text: "Ruche: " + rucheName + " (ID: " + rucheId + ")"
        font.pixelSize: 24
        font.bold: true
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Column {
        width: parent.width
        spacing: 10
        anchors.top: rucheTitle.bottom
        anchors.topMargin: 20

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                id: capteurComboBox
                width: 200
                model: ListModel {
                    id: capteurComboModel
                }
                textRole: "name"

                onActivated: function(index) {
                    var selectedId = capteurComboModel.get(index).id;
                    if (selectedId === -1) {
                        showAllCapteurs = true;
                        capteurSelectionne = -1;
                    } else {
                        showAllCapteurs = false;
                        capteurSelectionne = selectedId;
                    }
                    console.log("Sélection:", showAllCapteurs ? "Tous les capteurs" : ("Capteur ID " + capteurSelectionne));
                    refreshChartData();
                }
            }

            Button {
                text: "Capteurs"
                onClicked: stackLayout.currentIndex = 0
            }

            Button {
                text: "Graphique"
                onClicked: stackLayout.currentIndex = 1
            }

            Button {
                text: "Données"
                onClicked: stackLayout.currentIndex = 2
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            height: 300
            currentIndex: 0

            // Page 1: Liste des capteurs
            CapteursList {
                id: capteursList
                isViewA: root.isViewA

                // Éviter le binding direct
                Component.onCompleted: {
                    // Passer une copie des données
                    capteursList.updateCapteurs(capteursData);
                }

                onCapteurSelected: function(capteurId) {
                    capteurSelectionne = capteurId;
                    showAllCapteurs = false;
                    refreshChartData();
                    stackLayout.currentIndex = 1; // Passer à l'affichage graphique
                }

                // Relayer les signaux vers le parent
                onCapteurDeleted: function(capteurId) {
                    capteurDeletedRequest(capteurId);
                }

                onAddCapteurRequested: function() {
                    capteurAddRequest();
                }
            }

            // Page 2: Graphique
            GraphView {
                id: graphView
                capteurType: selectedCapteurType
            }

            // Page 3: Tableau de données
            DataTable {
                id: dataTable
                capteurType: selectedCapteurType
            }
        }
    }

    // Surveiller les changements dans capteursData pour mettre à jour CapteursList
    onCapteursDataChanged: {
        if (capteursList) {
            capteursList.updateCapteurs(JSON.parse(JSON.stringify(capteursData)));
        }
    }
}
