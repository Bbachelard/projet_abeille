<?php
include 'verif_session.php';
include 'connexion.php';

// Vérification de la ruche sélectionnée
if (!isset($_SESSION["id_ruche"])) {
    header("Location: login.php");
    exit();
}

$id_ruche = $_SESSION["id_ruche"];
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
        <h2>Galerie d'Images de la Ruche</h2>
        <div class="gallery">
            <?php
            // Requête pour récupérer les images associées à la ruche de l'utilisateur
            $query = "SELECT chemin_fichier, date_capture 
                      FROM images 
                      WHERE id_ruche = :id_ruche 
                      ORDER BY date_capture DESC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(":id_ruche", $id_ruche, PDO::PARAM_INT);
            $stmt->execute();
            $images = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (!empty($images)) {
                foreach ($images as $row):
                    // Nettoyer le chemin de l'image
                    $imagePath = str_replace('/ruche_connectee/', '/', $row['chemin_fichier']);
            ?>
                    <div class="image">
                        <a href="<?= htmlspecialchars($imagePath) ?>" target="_blank">
                            <img src="<?= htmlspecialchars($imagePath) ?>" alt="Image de la ruche">
                        </a>
                        <p>Date : <?= htmlspecialchars($row['date_capture']) ?></p>
                    </div>
            <?php
                endforeach;
            } else {
                echo "<p>Aucune image disponible pour cette ruche.</p>";
            }
            ?>
        </div>
    </main>

    <script src="/theme.js"></script>
    <script src="script.js" defer></script>
</body>
</html>
