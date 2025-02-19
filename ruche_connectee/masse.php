<?php include 'connexion.php'; ?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Masse - Ruche Connectée</title>
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
            <a href="temperature.php" class="graph-button">Température</a>
            <a href="humidite.php" class="graph-button">Humidité</a>
        </div>
        <h2>Graphique de la Masse</h2>
        <canvas id="masseChart"></canvas> 
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('get_data.php?capteur=masse')
                .then(response => response.json())
                .then(data => {
                    new Chart(document.getElementById("masseChart"), {
                        type: 'line',
                        data: {
                            labels: data.dates,
                            datasets: [{
                                label: "Masse (kg)",
                                data: data.valeurs,
                                borderColor: "green",
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
