<?php include 'connexion.php'; ?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Humidité - Ruche Connectée</title>
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
            <a href="masse.php" class="graph-button">Masse</a>
        </div>
        <h2>Graphique de l'Humidité</h2>
        <canvas id="humiditeChart"></canvas>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('get_data.php?capteur=humidite')
                .then(response => response.json())
                .then(data => {
                    new Chart(document.getElementById("humiditeChart"), {
                        type: 'line',
                        data: {
                            labels: data.dates,
                            datasets: [{
                                label: "Humidité (%)",
                                data: data.valeurs,
                                borderColor: "blue",
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
