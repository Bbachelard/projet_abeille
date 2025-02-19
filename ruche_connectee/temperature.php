<?php include 'connexion.php'; ?>

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
        <div class="button-container">
            <a href="humidite.php" class="graph-button">Humidité</a>
            <a href="masse.php" class="graph-button">Masse</a>
        </div>
        <h2>Graphique de la Température</h2>
        <canvas id="temperatureChart"></canvas>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('get_data.php?capteur=temperature')
                .then(response => response.json())
                .then(data => {
                    new Chart(document.getElementById("temperatureChart"), {
                        type: 'line',
                        data: {
                            labels: data.dates,
                            datasets: [{
                                label: "Température (°C)",
                                data: data.valeurs,
                                borderColor: "red",
                                fill: false
                            }]
                        }
                    });
                });
        });
    </script>
    <script src="/ruche_connectee/theme.js"></script>
</body>
</html>
