<?php
include 'connexion.php';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Capteurs - Ruche Connectée</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <?php include 'menu.php'; ?>

    <main>
        <h2>Liste des Capteurs</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Type</th>
                <th>Localisation</th>
                <th>Description</th>
            </tr>
            <?php
            $query = "SELECT * FROM capteurs";
            $result = $conn->query($query);

            while ($row = $result->fetch_assoc()):
            ?>
                <tr>
                    <td><?= htmlspecialchars($row['id_capteur']) ?></td>
                    <td><?= htmlspecialchars($row['type']) ?></td>
                    <td><?= htmlspecialchars($row['localisation']) ?></td>
                    <td><?= htmlspecialchars($row['description']) ?></td>
                </tr>
            <?php endwhile; ?>
        </table>
    </main>

</body>
</html>
