<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Images - Ruche Connectée</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Images Capturées</h1>
    </header>
    <main>
        <h2>Galerie d'images</h2>
        <?php
        include 'db_config.php';

        $sql = "SELECT * FROM images ORDER BY date_capture DESC";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            echo "<div class='gallery'>";
            while ($row = $result->fetch_assoc()) {
                echo "<div class='image'>";
                echo "<img src='" . htmlspecialchars($row['chemin_fichier']) . "' alt='Image capturée'>";
                echo "<p>Date : " . htmlspecialchars($row['date_capture']) . "</p>";
                echo "</div>";
            }
            echo "</div>";
        } else {
            echo "<p>Aucune image trouvée.</p>";
        }
        ?>
    </main>
</body>
</html>
