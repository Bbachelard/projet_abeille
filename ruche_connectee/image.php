<?php
include 'verif_session.php';
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

    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Galerie d'Images</h2>
        <div class="gallery">
            <?php
            $query = "SELECT chemin_fichier, date_capture FROM images ORDER BY date_capture DESC";
            $stmt = $conn->query($query);

            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)):
            ?>
                <div class="image">
                    <img src="<?= htmlspecialchars($row['chemin_fichier']) ?>" alt="Image de la ruche : ">
                    <p>Date : <?= htmlspecialchars($row['date_capture']) ?></p>
                </div>
            <?php endwhile; ?>
        </div>
    </main>

    <script src="/ruche_connectee/theme.js"></script>
    <script src="notifications_animation.js"></script>
    <script src="script.js" defer></script>
</body>
</html>
