import QtQuick 2.15
import com.example.ruche 1.0

QtObject {
    id: dataManagerRoot
    property var backendManager: null
    signal dataLoaded(var data)
    signal chartDataLoaded(var data, var minDate, var maxDate, string capteurType, bool isMultiple)
    function initialize(backend) {
        backendManager = backend;
    }
    function loadRucheData(rucheId) {
        if (rucheId > 0 && backendManager) {
            var dataTmp = backendManager.getRucheData(rucheId);
            var capteursData = dataTmp ? JSON.parse(JSON.stringify(dataTmp)) : [];
            dataLoaded(capteursData);
            return capteursData;
        }
        return [];
    }
    function loadSingleCapteurData(rucheId, capteurId, capteursList) {
        if (rucheId > 0 && capteurId > 0 && backendManager) {
            var data = backendManager.getCapteurGraphData(rucheId, capteurId);
            var selectedCapteurType = "";

            data = data ? JSON.parse(JSON.stringify(data)) : [];

            for (var k = 0; k < capteursList.length; k++) {
                if (capteursList[k].id_capteur === capteurId) {
                    selectedCapteurType = capteursList[k].type;
                    break;
                }
            }

            var minDate = new Date();
            var maxDate = new Date(0);
            var hasValidDates = false;
            for (var l = 0; l < data.length; l++) {
                if (data[l].date_mesure) {
                    var date = new Date(data[l].date_mesure);
                    if (!isNaN(date.getTime())) {
                        minDate = date < minDate ? date : minDate;
                        maxDate = date > maxDate ? date : maxDate;
                        hasValidDates = true;
                    }
                }
            }

            // Émettre le signal avec les données
            chartDataLoaded(data, minDate, maxDate, selectedCapteurType, false);
            return {
                data: data,
                minDate: minDate,
                maxDate: maxDate,
                capteurType: selectedCapteurType
            };
        }
        return null;
    }

    // Fonction pour charger les données de tous les capteurs
    function loadAllCapteursData(rucheId, capteursList) {
        if (rucheId > 0 && backendManager) {
            var allData = [];
            var minDate = new Date();
            var maxDate = new Date(0);
            var hasValidDates = false;
            for (var i = 0; i < capteursList.length; i++) {
                var capteurId = capteursList[i].id_capteur;
                var capteurType = capteursList[i].type;
                var capteurData = backendManager.getCapteurGraphData(rucheId, capteurId);
                capteurData = capteurData ? JSON.parse(JSON.stringify(capteurData)) : [];
                for (var j = 0; j < capteurData.length; j++) {
                    capteurData[j].capteurType = capteurType;
                    capteurData[j].capteurId = capteurId;
                    if (capteurData[j].date_mesure) {
                        var date = new Date(capteurData[j].date_mesure);
                        if (!isNaN(date.getTime())) {
                            minDate = date < minDate ? date : minDate;
                            maxDate = date > maxDate ? date : maxDate;
                            hasValidDates = true;
                        }
                    }
                }
                allData = allData.concat(capteurData);
            }
            chartDataLoaded(allData, minDate, maxDate, "Tous les capteurs", true);
            return {
                data: allData,
                minDate: minDate,
                maxDate: maxDate,
                capteurType: "Tous les capteurs"
            };
        }
        return null;
    }

    // Fonction principale pour charger les données du graphique
    function loadChartData(rucheId, capteurId, capteursList, showAllCapteurs) {
        if (showAllCapteurs) {
            return loadAllCapteursData(rucheId, capteursList);
        } else {
            return loadSingleCapteurData(rucheId, capteurId, capteursList);
        }
    }
}
