<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - Ruche Connectée</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Ruche Connectée</h1>
    </header>
    <main>
        <h2>Résumé des dernières données</h2>
        <?php
        include 'db_config.php';

        $query = "SELECT c.type, d.valeur, d.date_mesure 
                  FROM donnees d
                  JOIN capteurs c ON d.id_capteur = c.id_capteur
                  ORDER BY d.date_mesure DESC LIMIT 5";
        $result = $conn->query($query);

        if ($result->num_rows > 0) {
            echo "<table><tr><th>Type</th><th>Valeur</th><th>Date</th></tr>";
            while ($row = $result->fetch_assoc()) {
                echo "<tr><td>" . htmlspecialchars($row['type']) . "</td>";
                echo "<td>" . htmlspecialchars($row['valeur']) . "</td>";
                echo "<td>" . htmlspecialchars($row['date_mesure']) . "</td></tr>";
            }
            echo "</table>";
        } else {
            echo "<p>Aucune donnée disponible.</p>";
        }
        ?>
    </main>
</body>
</html>
