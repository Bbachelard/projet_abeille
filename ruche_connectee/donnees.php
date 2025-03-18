<?php
include 'verif_session.php';
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Données - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Données des capteurs</h2>
        <table>
            <tr>
                <th>Type de Capteur</th>
                <th>Valeur</th>
                <th>Date</th>
            </tr>
            <?php
            $query = "SELECT capteurs.type, donnees.valeur, donnees.date_mesure 
                      FROM donnees 
                      JOIN capteurs ON donnees.id_capteur = capteurs.id_capteur 
                      ORDER BY donnees.date_mesure DESC 
                      LIMIT 10";
            $stmt = $conn->prepare($query);
            $stmt->execute();

            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)):
            ?>
                <tr>
                    <td><?= htmlspecialchars($row['type']) ?></td>
                    <td><?= htmlspecialchars($row['valeur']) ?></td>
                    <td><?= htmlspecialchars($row['date_mesure']) ?></td>
                </tr>
            <?php endwhile; ?>
        </table>
    </main>

    <script src="/ruche_connectee/theme.js"></script>
    <script src="notifications_animation.js"></script>
    <script src="script.js" defer></script>
</body>
</html>
