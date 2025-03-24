import QtQuick 2.15
import com.example.ruche 1.0

// Classe utilitaire pour gérer les données des ruches et capteurs
QtObject {
    id: dataManagerRoot

    // Propriétés
    property var backendManager: null  // Renommé pour éviter la confusion avec dManager

    // Signaux pour notifier les changements de données
    signal dataLoaded(var data)
    signal chartDataLoaded(var data, var minDate, var maxDate, string capteurType, bool isMultiple)

    // Fonction pour initialiser le gestionnaire
    function initialize(backend) {
        // Assignation sans créer de binding
        backendManager = backend;
    }

    // Fonction pour charger les données d'une ruche
    function loadRucheData(rucheId) {
        if (rucheId > 0 && backendManager) {
            var dataTmp = backendManager.getRucheData(rucheId);
            var capteursData = dataTmp ? JSON.parse(JSON.stringify(dataTmp)) : []; // Copie profonde pour éviter les bindings
            dataLoaded(capteursData);
            return capteursData;
        }
        return [];
    }

    // Fonction pour charger les données d'un capteur spécifique
    function loadSingleCapteurData(rucheId, capteurId, capteursList) {
        if (rucheId > 0 && capteurId > 0 && backendManager) {
            var data = backendManager.getCapteurGraphData(rucheId, capteurId);
            var selectedCapteurType = "";

            // Créer une copie de data pour éviter les bindings
            data = data ? JSON.parse(JSON.stringify(data)) : [];

            // Trouver le type du capteur
            for (var k = 0; k < capteursList.length; k++) {
                if (capteursList[k].id_capteur === capteurId) {
                    selectedCapteurType = capteursList[k].type;
                    break;
                }
            }

            // Déterminer min/max dates
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

            // Récupérer les données pour chaque capteur
            for (var i = 0; i < capteursList.length; i++) {
                var capteurId = capteursList[i].id_capteur;
                var capteurType = capteursList[i].type;
                var capteurData = backendManager.getCapteurGraphData(rucheId, capteurId);

                // Créer une copie de capteurData pour éviter les bindings
                capteurData = capteurData ? JSON.parse(JSON.stringify(capteurData)) : [];

                // Ajouter le type à chaque mesure
                for (var j = 0; j < capteurData.length; j++) {
                    capteurData[j].capteurType = capteurType;
                    capteurData[j].capteurId = capteurId;

                    // Mettre à jour min/max dates
                    if (capteurData[j].date_mesure) {
                        var date = new Date(capteurData[j].date_mesure);
                        if (!isNaN(date.getTime())) {
                            minDate = date < minDate ? date : minDate;
                            maxDate = date > maxDate ? date : maxDate;
                            hasValidDates = true;
                        }
                    }
                }

                // Ajouter au tableau global
                allData = allData.concat(capteurData);
            }

            // Émettre le signal avec les données
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
