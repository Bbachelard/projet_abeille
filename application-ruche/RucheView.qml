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
    property var ruche: null
    property var rucheData: []
    property var capteursData: []

    property int capteurSelectionne: 1
    property var graphData: []
    property string selectedCapteurType: ""
    property bool showAllCapteurs: false
    property double rucheBattery: 0
    property string backgroundSource: ""
    property int returnDirection: 1
    property bool isViewA: false
    signal capteurDeletedRequest(int capteurId)

    signal capteurAddRequest()
    DataManager {
        id: dataManager

        onDataLoaded: function(data) {
            capteursData = JSON.parse(JSON.stringify(data));
            updateCapteurComboBox();
        }

        onChartDataLoaded: function(data, minDate, maxDate, capteurType, isMultiple) {
            graphData = JSON.parse(JSON.stringify(data));
            selectedCapteurType = capteurType;
            updateGraphView(data, minDate, maxDate, capteurType, isMultiple);
            updateDataTable(data, capteurType);
        }
    }

    Component.onCompleted: {
        dataManager.initialize(dManager);
        if (rucheData && rucheData.length > 0) {
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
    function refreshData() {
        if (rucheId > 0) {
            var data = dataManager.loadRucheData(rucheId);
            if (data && data.length > 0) {
                capteursData = JSON.parse(JSON.stringify(data));
            }
        }
    }
    function refreshChartData() {
        if (rucheId > 0) {
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
        graphView.chartData = JSON.parse(JSON.stringify(data));
        graphView.chartTitle = isMultiple ? "Évolution de tous les capteurs" : ("Évolution des " + capteurType);
        graphView.capteurType = capteurType;
        graphView.showAllCapteurs = isMultiple;
        graphView.minDate = minDate;
        graphView.maxDate = maxDate;
        graphView.initGraphValues();
    }
    function updateDataTable(data, capteurType) {
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

                Rectangle {
                    width: 2
                    height: 10
                    color: "#333333"
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, rucheBattery / 100))
                    height: parent.height - 2
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter

                    color: {
                        if (rucheBattery > 60) return "#4CAF50";  // Vert
                        if (rucheBattery > 30) return "#FFC107";  // Jaune
                        return "#F44336";  // Rouge
                    }
                }

            }

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
        text: "Actualiser"
        width: 120
        height: 40
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 90
            topMargin: 10
        }
        onClicked: {
            refreshData();
            loadRucheBattery();
            refreshChartData();
            imageGallery.chargerImages();
            successMessage.text = "Données actualisées";
            successMessage.visible = true;
            successTimer.restart();
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
            Button {
                text: "Images"
                onClicked: stackLayout.currentIndex = 3
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            height: 300
            currentIndex: 0

            CapteursList {
                id: capteursList
                isViewA: root.isViewA
                rucheId: root.rucheId
                Component.onCompleted: {
                    capteursList.updateCapteurs(capteursData);
                }

                onCapteurSelected: function(capteurId) {
                    capteurSelectionne = capteurId;
                    showAllCapteurs = false;
                    refreshChartData();
                    stackLayout.currentIndex = 1;
                }

                // Relayer les signaux vers le parent
                onCapteurDeleted: function(capteurId) {
                    capteurDeletedRequest(capteurId);
                }

                onAddCapteurRequested: function() {
                    capteurAddRequest();
                }
                onShowImagesRequested: function(rucheId) {
                    stackLayout.currentIndex = 3; // Passer directement à l'onglet Images
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
            // Page 4: Galerie d'images
            ImageGallery {
                id: imageGallery
                rucheId: root.rucheId
                rucheName: root.rucheName
                isAdmin: root.isViewA
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
