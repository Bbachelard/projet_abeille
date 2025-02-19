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
    <?php include 'menu.php'; ?>

    <main>
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
