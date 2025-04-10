<?php
session_start();
include 'connexion.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

$query = "SELECT id_ruche, name FROM ruche"; 
$stmt = $conn->query($query);
$ruches = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Menu - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="menu">
        <ul>
            <li><a href="index.php"><i class="fas fa-home"></i> Accueil</a></li>
            <li><a href="capteur.php"><i class="fas fa-thermometer-half"></i> Capteurs</a></li>
            <li><a href="donnees.php"><i class="fas fa-chart-line"></i> Données</a></li>
            <li><a href="image.php"><i class="fas fa-image"></i> Galerie</a></li>
            <li><a href="graphique.php"><i class="fas fa-chart-bar"></i> Graphique</a></li>
            <li><a href="#" id="dark-mode-toggle"><i class="fas fa-moon"></i> Mode sombre</a></li>
            <li><a href="logout.php"><i class="fas fa-sign-out-alt"></i> Déconnexion</a></li>
        </ul>

        <!-- Sélection de la ruche -->
        <form method="POST" action="ruche.php" class="ruche-form">
            <label for="ruche-select">🌿 Ruche :</label>
            <select name="id_ruche" id="ruche-select" onchange="this.form.submit()">
                <?php foreach ($ruches as $ruche) : ?>
                    <option value="<?= htmlspecialchars($ruche['id_ruche']) ?>" 
                        <?= ($_SESSION["id_ruche"] ?? '') == $ruche['id_ruche'] ? 'selected' : '' ?>>
                        <?= htmlspecialchars($ruche['name']) ?>  <!-- 🛠 Correction: 'name' au lieu de 'nom' -->
                    </option>
                <?php endforeach; ?>
            </select>
        </form>
    </nav>
</body>
</html>
