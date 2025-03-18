<?php
session_start(); // Démarrer la session

// Si l'utilisateur est déjà connecté, on le redirige vers index.php
if (isset($_SESSION["user_id"])) {
    header("Location: index.php");
    exit();
}

include 'connexion.php'; // Connexion à la base de données

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $identifiant = $_POST['identifiant'];
    $password = $_POST['password'];

    $query = "SELECT * FROM compte WHERE identifiant = :identifiant";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(":identifiant", $identifiant, PDO::PARAM_STR);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user["password"])) {
        $_SESSION["user_id"] = $user["id_compte"];
        $_SESSION["identifiant"] = $user["identifiant"];
        $_SESSION["grade"] = $user["grade"];
        header("Location: index.php");
        exit();
    } else {
        $error = "Identifiant ou mot de passe incorrect.";
    }
}
?>
