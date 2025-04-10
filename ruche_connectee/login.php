<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

session_start();
include 'connexion.php'; // Connexion à SQLite

$error = "";

// Récupération des ruches disponibles
$query = "SELECT id_ruche, name FROM ruche";
$stmt = $conn->query($query);
$ruches = $stmt->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $identifiant = $_POST['identifiant'];
    $password = $_POST['password'];
    $id_ruche = $_POST['ruche'];

    $query = "SELECT id_compte, identifiant, password, grade FROM compte WHERE identifiant = :identifiant";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(":identifiant", $identifiant, PDO::PARAM_STR);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user["password"])) {
        $_SESSION["user_id"] = $user["id_compte"];
        $_SESSION["identifiant"] = $user["identifiant"];
        $_SESSION["grade"] = $user["grade"];
        $_SESSION["id_ruche"] = $id_ruche; // Stocker la ruche sélectionnée

        header("Location: index.php");
        exit();
    } else {
        $error = "Identifiant ou mot de passe incorrect.";
    }
}

// Si l'utilisateur est déjà connecté, on le redirige
if (isset($_SESSION["user_id"])) {
    header("Location: index.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Connexion</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <main>
        <h2>Connexion</h2>

        <?php if (!empty($error)) : ?>
            <p style="color: red;"><?= htmlspecialchars($error) ?></p>
        <?php endif; ?>

        <form method="POST" action="login.php">
            <label for="identifiant">Identifiant :</label>
            <input type="text" id="identifiant" name="identifiant" required>

            <label for="password">Mot de passe :</label>
            <input type="password" id="password" name="password" required>

            <label for="ruche">Sélectionnez une ruche :</label>
            <select id="ruche" name="ruche" required>
                <?php foreach ($ruches as $ruche) : ?>
                    <option value="<?= htmlspecialchars($ruche['id_ruche']) ?>">
                        <?= htmlspecialchars($ruche['name']) ?>
                    </option>
                <?php endforeach; ?>
            </select>

            <button type="submit">Se connecter</button>
        </form>
    </main>
</body>
</html>
