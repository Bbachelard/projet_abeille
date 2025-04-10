<?php
session_start();
include 'connexion.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['id_ruche'])) {
    $_SESSION["id_ruche"] = $_POST['id_ruche'];
}

if (!isset($_SESSION["id_ruche"])) {
    die("Erreur : Impossible de changer de ruche.");
}

header("Location: " . ($_SERVER['HTTP_REFERER'] ?? 'index.php'));
exit();
?>
