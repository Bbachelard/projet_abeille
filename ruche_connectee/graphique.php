<?php
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Graphiques - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>
    
    <?php include 'menu.php'; ?>

    <main>
        <h2>Visualisation des données</h2>

        <div class="button-container">
            <a href="temperature.php" class="graph-button">Température</a>
            <a href="humidite.php" class="graph-button">Humidité</a>
            <a href="masse.php" class="graph-button">Masse</a>
        </div>
    </main>
    <script src="/ruche_connectee/theme.js"></script>
</body>
</html>


