<?php
include 'verif_session.php';
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Température - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Graphique de la Température</h2>

        <div class="button-container">
            <a href="humidite.php" class="graph-button">Humidité</a>
            <a href="masse.php" class="graph-button">Masse</a>
        </div>

        <button class="filter-btn" onclick="loadChart('week')">📅 Dernière semaine</button>
        <button class="filter-btn" onclick="loadChart('month')">📅 Dernier mois</button>
        <button class="filter-btn" onclick="loadChart('all')">📅 Tout</button>

        <canvas id="temperatureChart"></canvas>
    </main>

    <script>
        function loadChart(periode) {
            fetch(`get_data.php?capteur=temperature&periode=${periode}`)
                .then(response => response.json())
                .then(data => {
                    if (!data.dates.length) {
                        console.error("Aucune donnée reçue !");
                        return;
                    }
                    new Chart(document.getElementById("temperatureChart"), {
                        type: 'line',
                        data: {
                            labels: data.dates,
                            datasets: [{
                                label: "Température (°C)",
                                data: data.valeurs,
                                borderColor: "red",
                                backgroundColor: "rgba(255, 0, 0, 0.2)",
                                borderWidth: 2,
                                tension: 0.4,
                                fill: true
                            }]
                        }
                    });
                }).catch(error => console.error("Erreur lors du fetch :", error));
        }

        document.addEventListener("DOMContentLoaded", function() {
            loadChart('all');
        });
    </script>

    <script src="/ruche_connectee/theme.js"></script>
    <script src="notifications_animation.js"></script>
    <script src="script.js" defer></script
</body>
</html>
