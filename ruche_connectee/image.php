<?php
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Images - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Galerie d'Images</h2>
        <div class="gallery">
            <?php
            $query = "SELECT chemin_fichier, date_capture FROM images ORDER BY date_capture DESC";
            $result = $conn->query($query);

            while ($row = $result->fetch_assoc()):
            ?>
                <div class="image">
                    <img src="<?= htmlspecialchars($row['chemin_fichier']) ?>" alt="Image de la ruche">
                    <p>Date : <?= htmlspecialchars($row['date_capture']) ?></p>
                </div>
            <?php endwhile; ?>
        </div>
    </main>

</body>
</html>
