import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: graphRoot
    width: 800
    height: 400

    // Propriétés du graphique
    property var chartData: []
    property string chartTitle: "Graphique"
    property string capteurType: ""
    property var minDate: new Date()
    property var maxDate: new Date()

    // Propriétés pour le zoom et le déplacement
    property real zoomFactor: 1.0
    property real panOffset: 0

    // Définir les graduations en fonction du type de capteur
    property var yAxisLabels: []
    property real minValue: 0
    property real maxValue: 100
    property bool showAllCapteurs: false

    property var capteurColors: {
        "température": "#FF0000",
        "humidité": "#0000FF",
        "masse": "#008800",
        "pression": "#FF6600"
    }

    // Fonction d'initialisation
    function initGraphValues() {
        // Définir les valeurs min/max et les graduations en fonction du type de capteur
        if (capteurType.toLowerCase().includes("température") || capteurType.toLowerCase().includes("temperature")) {
            minValue = 0;
            maxValue = 40;
            yAxisLabels = [0, 5, 10, 15, 20, 25, 30, 35, 40];
        } else if (capteurType.toLowerCase().includes("humidité") || capteurType.toLowerCase().includes("humidite")) {
            minValue = 0;
            maxValue = 100;
            yAxisLabels = [0, 20, 40, 60, 80, 100];
        } else if (capteurType.toLowerCase().includes("poids") || capteurType.toLowerCase().includes("masse")) {
            minValue = 0;
            maxValue = 100;
            yAxisLabels = [0, 20, 40, 60, 80, 100];
        } else if (capteurType.toLowerCase().includes("pression")) {
            minValue = 900;
            maxValue = 1100;
            yAxisLabels = [900, 950, 1000, 1050, 1100];
        } else {
            // Valeurs par défaut ou calculées à partir des données
            calculateMinMaxFromData();
        }

        chartCanvas.requestPaint();
    }

    // Calculer min/max à partir des données
    function calculateMinMaxFromData() {
        if (!chartData || chartData.length === 0) return;

        var min = Number.MAX_VALUE;
        var max = Number.MIN_VALUE;

        for (var i = 0; i < chartData.length; i++) {
            var value = parseFloat(chartData[i].valeur);
            if (!isNaN(value)) {
                min = Math.min(min, value);
                max = Math.max(max, value);
            }
        }

        // Ajouter une marge
        var range = max - min;
        minValue = Math.max(0, min - range * 0.1);
        maxValue = max + range * 0.1;

        // Générer des graduations
        yAxisLabels = [];
        var step = (maxValue - minValue) / 5;
        for (var j = 0; j <= 5; j++) {
            yAxisLabels.push(Math.round((minValue + j * step) * 10) / 10);
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Données du capteur: " + capteurType
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // Contrôles de zoom et déplacement
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            Button {
                text: "-"
                width: 40
                onClicked: {
                    if (zoomFactor > 1) {
                        zoomFactor -= 1;
                        chartCanvas.requestPaint();
                    }
                }
            }

            Text {
                text: "Zoom: " + zoomFactor.toFixed(1) + "x"
                anchors.verticalCenter: parent.verticalCenter
            }

            Button {
                text: "+"
                width: 40
                onClicked: {
                    zoomFactor += 1;
                    chartCanvas.requestPaint();
                }
            }

            Button {
                text: "◀"
                width: 40
                enabled: panOffset > 0
                onClicked: {
                    if (panOffset > 0) {
                        panOffset -= 0.1;
                        if (panOffset < 0) panOffset = 0;
                        chartCanvas.requestPaint();
                    }
                }
            }

            Button {
                text: "▶"
                width: 40
                enabled: panOffset < (zoomFactor - 1)
                onClicked: {
                    if (panOffset < (zoomFactor - 1)) {
                        panOffset += 0.1;
                        if (panOffset > (zoomFactor - 1)) panOffset = zoomFactor - 1;
                        chartCanvas.requestPaint();
                    }
                }
            }

            Button {
                text: "Reset"
                onClicked: {
                    zoomFactor = 1.0;
                    panOffset = 0;
                    chartCanvas.requestPaint();
                }
            }
        }

        // Rectangle pour le graphique
        Rectangle {
            id: chartRect
            width: 740
            height: 240
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "#aaaaaa"
            border.width: 1
            radius: 5

            Text {
                id: titleText
                text: chartTitle
                font.pixelSize: 14
                font.bold: true
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 5
            }

            Canvas {
                id: chartCanvas
                width: parent.width - 80
                height: parent.height - 60
                anchors.centerIn: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    // Dessiner les axes
                    ctx.strokeStyle = "#000000";
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(0, height);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(width, 0);
                    ctx.stroke();

                    // Dessiner la grille verticale et les graduations en Y
                    ctx.strokeStyle = "#cccccc";
                    ctx.fillStyle = "#0066cc";

                    for (var i = 0; i < yAxisLabels.length; i++) {
                        var labelValue = yAxisLabels[i];
                        var y = height - ((labelValue - minValue) / (maxValue - minValue)) * height;

                        // Ligne horizontale
                        ctx.beginPath();
                        ctx.setLineDash([2, 2]);
                        ctx.moveTo(0, y);
                        ctx.lineTo(width, y);
                        ctx.stroke();
                        ctx.setLineDash([]);

                        // Étiquette de valeur
                        var valueLabel = labelValue.toString();
                        if (capteurType.toLowerCase().includes("température")) {
                            valueLabel += "°C";
                        } else if (capteurType.toLowerCase().includes("humidité")) {
                            valueLabel += "%";
                        } else if (capteurType.toLowerCase().includes("pression")) {
                            valueLabel += " hPa";
                        }
                        ctx.fillText(valueLabel, -40, y + 4);
                    }

                    // Dessiner les mois sur l'axe X
                    var months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];
                    var monthWidth = width / 12;

                    ctx.fillStyle = "#000000";
                    ctx.font = "10px sans-serif";
                    for (var m = 0; m < 12; m++) {
                        ctx.fillText(months[m], m * monthWidth + 5, height + 15);
                    }
                    if (chartData && chartData.length > 0) {
                        var visibleWidth = width / zoomFactor;
                        var startOffset = panOffset / zoomFactor * width;
                        var timeRange = maxDate.getTime() - minDate.getTime();

                        if (showAllCapteurs) {
                            // Regrouper les données par type de capteur
                            var dataByType = {};

                            // Initialiser les regroupements
                            for (var i = 0; i < chartData.length; i++) {
                                var point = chartData[i];
                                if (!dataByType[point.capteurType]) {
                                    dataByType[point.capteurType] = [];
                                }
                                dataByType[point.capteurType].push(point);
                            }

                            // Dessiner chaque type de capteur avec sa propre couleur
                            var types = Object.keys(dataByType);
                            for (var typeIndex = 0; typeIndex < types.length; typeIndex++) {
                                var typeName = types[typeIndex];
                                var typeData = dataByType[typeName];

                                // Définir la couleur en fonction du type ou utiliser une couleur par défaut
                                var color = capteurColors[typeName.toLowerCase()] || "#" + Math.floor(Math.random()*16777215).toString(16);
                                ctx.strokeStyle = color;
                                ctx.fillStyle = color;
                                ctx.lineWidth = 2;

                                // Dessiner la ligne pour ce type
                                ctx.beginPath();
                                var firstPoint = true;

                                for (var j = 0; j < typeData.length; j++) {
                                    var pt = typeData[j];
                                    var x = 0;

                                    if (pt.date_mesure) {
                                        var ptDate = new Date(pt.date_mesure);
                                        x = ((ptDate.getTime() - minDate.getTime()) / timeRange) * width;
                                    } else {
                                        x = (j / (typeData.length - 1)) * width;
                                    }

                                    x = (x * zoomFactor - startOffset * zoomFactor);

                                    if (x >= 0 && x <= width) {
                                        // Normaliser la valeur en fonction de minValue et maxValue
                                        var normalizedValue = Math.max(0, Math.min(1, (pt.valeur - minValue) / (maxValue - minValue)));
                                        var y = height - normalizedValue * height;

                                        if (firstPoint) {
                                            ctx.moveTo(x, y);
                                            firstPoint = false;
                                        } else {
                                            ctx.lineTo(x, y);
                                        }
                                    }
                                }

                                ctx.stroke();

                                // Dessiner les points pour ce type
                                for (var k = 0; k < typeData.length; k++) {
                                    var dataPoint = typeData[k];
                                    var ptX = 0;

                                    if (dataPoint.date_mesure) {
                                        var dataDate = new Date(dataPoint.date_mesure);
                                        ptX = ((dataDate.getTime() - minDate.getTime()) / timeRange) * width;
                                    } else {
                                        ptX = (k / (typeData.length - 1)) * width;
                                    }

                                    ptX = (ptX * zoomFactor - startOffset * zoomFactor);

                                    // Vérifier si le point est dans la zone visible
                                    if (ptX >= 0 && ptX <= width) {
                                        var normalizedVal = Math.max(0, Math.min(1, (dataPoint.valeur - minValue) / (maxValue - minValue)));
                                        var ptY = height - normalizedVal * height;

                                        ctx.beginPath();
                                        ctx.arc(ptX, ptY, 4, 0, 2 * Math.PI);
                                        ctx.fill();

                                        // Afficher la valeur au-dessus du point
                                        ctx.fillStyle = "black";
                                        ctx.fillText(dataPoint.valeur.toFixed(1), ptX - 10, ptY - 10);
                                        ctx.fillStyle = color; // Remettre la couleur pour le prochain point
                                    }
                                }

                                // Dessiner une légende pour ce type
                                ctx.fillStyle = color;
                                var legendX = 20 + typeIndex * 120;
                                var legendY = 20;
                                ctx.fillRect(legendX, legendY, 10, 10);
                                ctx.fillStyle = "black";
                                ctx.fillText(typeName, legendX + 15, legendY + 8);
                            }
                        } else {
                            // Code pour un seul capteur
                            ctx.strokeStyle = "#3366cc";
                            ctx.lineWidth = 2;
                            ctx.beginPath();

                            var zoomScale = zoomFactor;
                            var firstPoint = true;
                            for (var j = 0; j < chartData.length; j++) {
                                var point = chartData[j];
                                var x = 0;
                                if (point.date_mesure) {
                                    var date = new Date(point.date_mesure);
                                    x = ((date.getTime() - minDate.getTime()) / timeRange) * width;
                                } else {
                                    x = (j / (chartData.length - 1)) * width;
                                }
                                x = (x * zoomFactor - startOffset * zoomFactor);
                                if (x >= 0 && x <= width) {
                                    var y = height - ((point.valeur - minValue) / (maxValue - minValue)) * height;
                                    if (firstPoint) {
                                        ctx.moveTo(x, y);
                                        firstPoint = false;
                                    } else {
                                        ctx.lineTo(x, y);
                                    }
                                }
                            }
                            ctx.stroke();
                            ctx.fillStyle = "#3366cc";

                            for (var k = 0; k < chartData.length; k++) {
                                var pt = chartData[k];
                                var ptX = 0;

                                if (pt.date_mesure) {
                                    var ptDate = new Date(pt.date_mesure);
                                    ptX = ((ptDate.getTime() - minDate.getTime()) / timeRange) * width;
                                } else {
                                    ptX = (k / (chartData.length - 1)) * width;
                                }
                                ptX = (ptX * zoomFactor - startOffset * zoomFactor);

                                // Vérifier si le point est dans la zone visible
                                if (ptX >= 0 && ptX <= width) {
                                    var ptY = height - ((pt.valeur - minValue) / (maxValue - minValue)) * height;

                                    ctx.beginPath();
                                    ctx.arc(ptX, ptY, 4, 0, 2 * Math.PI);
                                    ctx.fill();

                                    // Ajouter un texte avec la valeur
                                    ctx.fillStyle = "black";
                                    ctx.fillText(pt.valeur.toFixed(1), ptX - 10, ptY - 10);
                                    ctx.fillStyle = "#3366cc"; // Remettre la bonne couleur
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "Mois"
                anchors.top: chartCanvas.bottom
                anchors.horizontalCenter: chartCanvas.horizontalCenter
                anchors.topMargin: 5
                font.pixelSize: 10
            }
            Row {
                anchors.bottom: parent.bottom
                anchors.left: chartCanvas.left
                anchors.right: chartCanvas.right
                anchors.bottomMargin: 5
                height: 20
                spacing: chartCanvas.width / 4

                Repeater {
                    model: 5
                    Text {
                        text: {
                            if (maxDate.getTime() > 0 && minDate.getTime() > 0) {
                                var dateRange = maxDate.getTime() - minDate.getTime();
                                var visibleDateRange = dateRange / zoomFactor;
                                var startOffset = panOffset / zoomFactor * dateRange;
                                var date = new Date(minDate.getTime() + startOffset + (index * visibleDateRange / 4));
                                return Qt.formatDateTime(date, "dd-MM-yyyy\nhh:mm");
                            }
                            return "";
                        }
                        font.pixelSize: 10
                    }
                }
            }

            // Titre axe Y
            Text {
                text: {
                    if (capteurType.toLowerCase().includes("température")) {
                        return "Température (°C)";
                    } else if (capteurType.toLowerCase().includes("humidité")) {
                        return "Humidité (%)";
                    } else if (capteurType.toLowerCase().includes("poids")) {
                        return "Poids (kg)";
                    } else if (capteurType.toLowerCase().includes("pression")) {
                        return "Pression (hPa)";
                    }
                    return "Valeur";
                }
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: chartCanvas.verticalCenter
                rotation: -90
                font.pixelSize: 12
            }
            Text {
                text: "Date"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: chartCanvas.horizontalCenter
                font.pixelSize: 12
            }
            MouseArea {
                anchors.fill: chartCanvas

                onWheel: {
                    if (wheel.angleDelta.y > 0) {
                        zoomFactor += 0.5;
                    } else {
                        if (zoomFactor > 1) zoomFactor -= 0.5;
                    }
                    chartCanvas.requestPaint();
                }

                property int lastX: 0
                property bool dragging: false

                onPressed: {
                    lastX = mouse.x;
                    dragging = true;
                }

                onPositionChanged: {
                    if (dragging && zoomFactor > 1) {
                        var deltaX = (mouse.x - lastX) / chartCanvas.width * zoomFactor;
                        panOffset -= deltaX;
                        if (panOffset < 0) panOffset = 0;
                        if (panOffset > (zoomFactor - 1)) panOffset = zoomFactor - 1;
                        lastX = mouse.x;
                        chartCanvas.requestPaint();
                    }
                }

                onReleased: {
                    dragging = false;
                }
            }
        }
    }
}
