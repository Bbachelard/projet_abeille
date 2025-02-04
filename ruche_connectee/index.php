<?php
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Accueil - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<?php

?>


    <?php include 'menu.php'; ?>

    <main>
        <h2>Dernières mesures</h2>
        <table>
            <tr>
                <th>Type</th>
                <th>Valeur</th>
                <th>Date</th>
            </tr>
            <?php
            $query = "SELECT capteurs.type, donnees.valeur, donnees.date_mesure 
                      FROM donnees 
                      JOIN capteurs ON donnees.id_capteur = capteurs.id_capteur 
                      ORDER BY donnees.date_mesure DESC LIMIT 5";
            $result = $conn->query($query);

            while ($row = $result->fetch_assoc()):
            ?>
                <tr>
                    <td><?= htmlspecialchars($row['type']) ?></td>
                    <td><?= htmlspecialchars($row['valeur']) ?></td>
                    <td><?= htmlspecialchars($row['date_mesure']) ?></td>
                </tr>
            <?php endwhile; ?>
        </table>
    </main>

</body>
</html>
