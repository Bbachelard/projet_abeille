<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Permet les requêtes AJAX

$servername = "localhost";
$username = "naxio"; 
$password = "NaXiolot63_";
$database = "ruche_connectee"; 

// Connexion à MySQL
$conn = new mysqli($servername, $username, $password, $database);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Erreur de connexion à la base de données"]);
    exit;
}

// Récupération de l'endpoint demandé
$request = $_GET['request'] ?? '';

if ($request === "sensors/active") {
    // Compte les capteurs actifs
    $result = $conn->query("SELECT COUNT(*) as active FROM capteurs WHERE actif = 1");
    $row = $result->fetch_assoc();
    echo json_encode(["active" => $row["active"]]);

} elseif ($request === "sensors/data") {
    // Récupère toutes les données des capteurs
    $result = $conn->query("SELECT id, temperature, humidity FROM capteurs");
    $sensors = [];
    while ($row = $result->fetch_assoc()) {
        $sensors[] = $row;
    }
    echo json_encode(["sensors" => $sensors]);

} else {
    http_response_code(404);
    echo json_encode(["error" => "Endpoint non trouvé"]);
}

$conn->close();
?>
