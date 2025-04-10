<?php
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Poids - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>
    
    <?php include 'menu.php'; ?>

    <main>
        <h2>Historique du Poids</h2>
        <table>
            <tr>
                <th>Poids (kg)</th>
                <th>Date</th>
            </tr>
            <?php
            $query = "SELECT valeur, date_mesure FROM poids ORDER BY date_mesure DESC LIMIT 10";
            $result = $conn->query($query);

            while ($row = $result->fetch_assoc()):
            ?>
                <tr>
                    <td><?= htmlspecialchars($row['valeur']) ?></td>
                    <td><?= htmlspecialchars($row['date_mesure']) ?></td>
                </tr>
            <?php endwhile; ?>
        </table>
    </main>
    <script src="/theme.js"></script>
</body>
</html>
