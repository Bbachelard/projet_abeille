<?php include 'verif_session.php';
$database = "/home/pi/nom_base.sqlite"; 

try {
    $conn = new PDO("sqlite:$database");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
?>
