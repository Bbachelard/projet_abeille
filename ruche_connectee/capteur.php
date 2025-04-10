<?php
include 'verif_session.php';
include 'connexion.php';

$id_ruche = $_SESSION['id_ruche'] ?? null;
if (!$id_ruche) {
    die("Aucune ruche sélectionnée.");
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Capteurs - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .alerte-moderate {
            background-color: #ffa500 !important;
            color: white;
            font-weight: bold;
        }
        .alerte-critique {
            background-color: #ff4d4d !important;
            color: white;
            font-weight: bold;
        }
        .alert-icon {
            font-weight: bold;
            cursor: help;
        }
    </style>
</head>
<body>
    <div class="hexagon top-left"></div>
    <div class="hexagon top-right"></div>
    <div class="hexagon bottom-left"></div>
    <div class="hexagon bottom-right"></div>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Liste des Capteurs</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Type</th>
                <th>Localisation</th>
                <th>Description</th>
                <th>Mesure</th>
                <th>Dernière Valeur</th>
                <th>Date</th>
                <th>Alerte</th>
            </tr>
            <?php
            $query = "
                SELECT c.id_capteur, c.type, c.localisation, c.description, c.mesure,
                       d.valeur AS derniere_valeur, d.date_mesure
                FROM capteurs c
                LEFT JOIN (
                    SELECT id_capteur, valeur, date_mesure
                    FROM donnees
                    WHERE id_ruche = :id_ruche
                    AND (id_capteur, date_mesure) IN (
                        SELECT id_capteur, MAX(date_mesure)
                        FROM donnees
                        WHERE id_ruche = :id_ruche
                        GROUP BY id_capteur
                    )
                ) d ON c.id_capteur = d.id_capteur
            ";

            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id_ruche', $id_ruche, PDO::PARAM_INT);
            $stmt->execute();

            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $alerte = false;
                $phrase_alerte = "";
                $niveau_alerte = null;
                $classe_alert = "";
                $icone = "";

                $valeur_mesure = $row['derniere_valeur'];

                $stmt_alert = $conn->prepare("SELECT nom, phrase, valeur, type FROM alertes WHERE id_capteur = :id_capteur AND statut = 1");
                $stmt_alert->bindParam(":id_capteur", $row['id_capteur'], PDO::PARAM_INT);
                $stmt_alert->execute();
                $alertes = $stmt_alert->fetchAll(PDO::FETCH_ASSOC);

                foreach ($alertes as $a) {
                    $nom = strtolower($a['nom']);
                    $valeur_seuil = $a['valeur'];
                    $phrase = $a['phrase'];
                    $type = $a['type'];

                    if ($type === null || $type === '') continue;

                    $declencher = false;

                    if (strpos($nom, 'min') !== false && $valeur_mesure < $valeur_seuil) {
                        $declencher = true;
                    } elseif (strpos($nom, 'max') !== false && $valeur_mesure > $valeur_seuil) {
                        $declencher = true;
                    }

                    if ($declencher && ($niveau_alerte === null || $type > $niveau_alerte)) {
                        $alerte = true;
                        $phrase_alerte = $phrase;
                        $niveau_alerte = $type;
                    }
                }

                if ($alerte) {
                    if ($niveau_alerte == 1) {
                        $classe_alert = "alerte-moderate";
                        $icone = "🔶";
                    } elseif ($niveau_alerte == 2) {
                        $classe_alert = "alerte-critique";
                        $icone = "🔴";
                    } else {
                        $icone = "⚠️";
                    }
                }

                echo "<tr" . ($alerte ? " class='{$classe_alert}'" : "") . ">";
                echo "<td>" . htmlspecialchars($row['id_capteur']) . "</td>";
                echo "<td>" . htmlspecialchars($row['type']) . "</td>";
                echo "<td>" . htmlspecialchars($row['localisation']) . "</td>";
                echo "<td>" . htmlspecialchars($row['description']) . "</td>";
                echo "<td>" . htmlspecialchars($row['mesure']) . "</td>";
                echo "<td>" . htmlspecialchars($valeur_mesure ?? '—') . "</td>";
                echo "<td>" . htmlspecialchars($row['date_mesure'] ?? '—') . "</td>";
                echo "<td>";
                if ($alerte) {
                    echo "<span class='alert-icon' title=\"" . htmlspecialchars($phrase_alerte) . "\">{$icone} " . htmlspecialchars($phrase_alerte) . "</span>";
                } else {
                    echo "—";
                }
                echo "</td>";
                echo "</tr>";
            }
            ?>
        </table>
    </main>

    <script src="/theme.js"></script>
</body>
</html>
