<?php
include 'verif_session.php'; // Vérification de connexion
include 'connexion.php'; // Connexion à la BDD

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
    <title>Accueil - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>

    <?php include 'menu.php'; ?>

    <main>
        <h1>Bienvenue sur la Ruche Connectée 🐝</h1>

        <section class="intro">
            <h2>Présentation du Projet</h2>
            <p>
                Ce projet a pour but de surveiller l'activité d'une ruche en temps réel grâce à divers capteurs
                et une caméra. Il permet d’analyser la santé des abeilles et d'optimiser la gestion de la ruche.
            </p>
        </section>

        <section class="ruche-info">
            <h2>Votre ruche actuelle</h2>
            <p>Vous suivez actuellement la ruche <strong>ID : <?= htmlspecialchars($id_ruche) ?></strong></p>
            <ul>
                <li>📷 <strong>Images en temps réel</strong> : Suivi de l’intérieur de la ruche.</li>
                <li>🌡 <strong>Température</strong> : Analyse des variations climatiques.</li>
                <li>💧 <strong>Humidité</strong> : Contrôle de l’humidité interne.</li>
                <li>⚖ <strong>Poids</strong> : Évaluation du miel stocké.</li>
                <li>🎚 <strong>Pression</strong> : Controle de la pression atmosphérique l'extérieur de la ruche.</li>
            </ul>
        </section>

        <section class="fonctionnalites">
            <h2>Fonctionnalités principales</h2>
            <div class="grid">
                <div class="feature">
                    <h3>📊 Statistiques</h3>
                    <p>Visualisation des données sous forme de graphiques interactifs.</p>
                </div>
                <div class="feature">
                    <h3>🔔 Alertes</h3>
                    <p>Notifications en cas de température ou poids anormal.</p>
                </div>
                <div class="feature">
                    <h3>📂 Historique</h3>
                    <p>Accès aux images et données des jours précédents.</p>
                </div>
                <div class="feature">
                    <h3>📡 Connexion IoT</h3>
                    <p>Transmission des données en temps réel via capteurs.</p>
                </div>
            </div>
        </section>

        <section class="cta">
            <h2>Commencez dès maintenant</h2>
            <p>
                Explorez les données de votre ruche et découvrez les analyses détaillées !
            </p>
            <a href="graphique.php" class="btn">Voir les Graphiques</a>
            <a href="image.php" class="btn">Galerie d’Images</a>
        </section>
    </main>

    <script src="/theme.js"></script>
    <script src="script.js"></script>

</body>
</html>

