<?php
session_start();

if (!isset($_SESSION["user_id"])) {
    // Si l'utilisateur n'est pas connecté ET qu'on n'est pas sur login.php, on le redirige
    if (basename($_SERVER["PHP_SELF"]) !== "login.php") {
        header("Location: login.php");
        exit();
    }
}
?>
