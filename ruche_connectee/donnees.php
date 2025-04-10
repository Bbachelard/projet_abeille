<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include 'verif_session.php';
include 'connexion.php';

if (!isset($_SESSION["id_ruche"])) {
    header("Location: login.php");
    exit();
}

$id_ruche = $_SESSION["id_ruche"];

// Récupération du seuil de miel
$query_seuil = "SELECT seuil_miel FROM ruche WHERE id_ruche = :id_ruche";
$stmt_seuil = $conn->prepare($query_seuil);
$stmt_seuil->bindParam(":id_ruche", $id_ruche, PDO::PARAM_INT);
$stmt_seuil->execute();
$seuil_miel = $stmt_seuil->fetchColumn();
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Données - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .separator {
            border-top: 3px solid #D6921E;
            height: 5px;
            background-color: #D6921E;
        }
        .dark-mode table {
            background: #222;
            color: white;
            border: 2px solid #D6921E;
        }
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
<?php include 'menu.php'; ?>

<main>
    <h2>Données des capteurs de la ruche</h2>
    <label for="filter">Filtrer par type :</label>
    <select id="filter">
        <option value="">Tous</option>
        <?php
        $query_types = "SELECT DISTINCT type FROM capteurs";
        $stmt_types = $conn->prepare($query_types);
        $stmt_types->execute();
        while ($row = $stmt_types->fetch(PDO::FETCH_ASSOC)) {
            echo "<option value='" . htmlspecialchars($row['type']) . "'>" . htmlspecialchars($row['type']) . "</option>";
        }
        ?>
    </select>

    <table id="data-table">
        <thead>
        <tr>
            <th data-column="type">Type de Capteur</th>
            <th data-column="valeur">Valeur</th>
            <th data-column="ratio">Poids / Seuil</th>
            <th data-column="date_mesure">Date</th>
            <th data-column="alerte">Alerte</th>
        </tr>
        </thead>
        <tbody>
        <?php
        $query = "SELECT capteurs.id_capteur, capteurs.type, donnees.valeur, donnees.date_mesure 
                  FROM donnees 
                  JOIN capteurs ON donnees.id_capteur = capteurs.id_capteur 
                  WHERE donnees.id_ruche = :id_ruche
                  ORDER BY donnees.date_mesure DESC 
                  LIMIT 100";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(":id_ruche", $id_ruche, PDO::PARAM_INT);
        $stmt->execute();

        $counter = 0;
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $type = $row['type'];
            $valeur = $row['valeur'];
            $date = $row['date_mesure'];
            $id_capteur = $row['id_capteur'];

            $affichage_seuil = strtolower($type) === "poids" && $seuil_miel ? htmlspecialchars($valeur) . " / " . htmlspecialchars($seuil_miel) : "—";
            $alerte = false;
            $niveau_alerte = null;
            $phrase_alerte = "";
            $classe_alert = "";
            $icone = "";

            if (strtolower($type) === "poids" && $seuil_miel && $valeur > $seuil_miel) {
                $alerte = true;
                $niveau_alerte = 2;
                $phrase_alerte = "Niveau de miel dépassé";
                $classe_alert = "alerte-critique";
                $icone = "🍯";
            }

            // Vérification dans la table alertes
            $stmt_alert = $conn->prepare("SELECT nom, phrase, valeur, type FROM alertes WHERE id_capteur = :id_capteur AND statut = 1");
            $stmt_alert->bindParam(":id_capteur", $id_capteur, PDO::PARAM_INT);
            $stmt_alert->execute();
            $alertes = $stmt_alert->fetchAll(PDO::FETCH_ASSOC);

            foreach ($alertes as $a) {
                $nom = strtolower($a['nom']);
                $valeur_seuil = $a['valeur'];
                $phrase = $a['phrase'];
                $type_alerte = $a['type'];

                $declencher = false;
                if (strpos($nom, 'min') !== false && $valeur < $valeur_seuil) {
                    $declencher = true;
                }
                if (strpos($nom, 'max') !== false && $valeur > $valeur_seuil) {
                    $declencher = true;
                }

                if ($declencher && ($niveau_alerte === null || $type_alerte > $niveau_alerte)) {
                    $alerte = true;
                    $niveau_alerte = $type_alerte;
                    $phrase_alerte = $phrase;
                }
            }

            // Classe et icône selon niveau d'alerte
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

            echo "<tr class='data-row " . ($alerte ? $classe_alert : "") . "'>";
            echo "<td>" . htmlspecialchars($type) . "</td>";
            echo "<td>" . htmlspecialchars($valeur) . "</td>";
            echo "<td>" . $affichage_seuil . "</td>";
            echo "<td>" . htmlspecialchars($date) . "</td>";
            echo "<td>";
            if ($alerte) {
                echo "<span class='alert-icon' title=\"" . htmlspecialchars($phrase_alerte) . "\">{$icone} " . htmlspecialchars($phrase_alerte) . "</span>";
            } else {
                echo "—";
            }
            echo "</td></tr>";

            $counter++;
            if ($counter % 4 == 0) {
                echo "<tr class='separator'><td colspan='5'></td></tr>";
            }
        }
        ?>
        </tbody>
    </table>
</main>

<script src="/theme.js"></script>
<script>
    document.getElementById("filter").addEventListener("change", function () {
        let filterValue = this.value;
        let rows = document.querySelectorAll("#data-table tbody .data-row");
        let visibleRows = [];

        rows.forEach(row => {
            let type = row.querySelector("td:first-child").textContent.trim();
            if (filterValue === "" || type === filterValue) {
                row.style.display = "";
                visibleRows.push(row);
            } else {
                row.style.display = "none";
            }
        });

        document.querySelectorAll("#data-table tbody .separator").forEach(sep => sep.remove());

        visibleRows.forEach((row, index) => {
            if ((index + 1) % 4 === 0 && index !== visibleRows.length - 1) {
                let sep = document.createElement("tr");
                sep.classList.add("separator");
                let sepTd = document.createElement("td");
                sepTd.colSpan = 5;
                sep.appendChild(sepTd);
                row.parentNode.insertBefore(sep, row.nextSibling);
            }
        });
    });
</script>
</body>
</html>
