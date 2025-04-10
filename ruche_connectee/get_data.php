<?php
include 'verif_session.php';
include 'connexion.php';

if (!isset($_SESSION["id_ruche"])) {
    echo json_encode(["error" => "Aucune ruche sélectionnée"]);
    exit();
}

$id_ruche = $_SESSION["id_ruche"]; 
$capteur = $_GET['capteur'] ?? '';
$periode = $_GET['periode'] ?? 'all';

$capteur_id_map = [
    'temperature' => 1,
    'humidite' => 2,
    'pression' => 3,
    'masse' => 4,
    'camera' => 5
];

if (!isset($capteur_id_map[$capteur])) {
    echo json_encode(["error" => "Capteur non trouvé"]);
    exit();
}

$id_capteur = $capteur_id_map[$capteur];

$query = "SELECT valeur, date_mesure FROM donnees WHERE id_capteur = :id_capteur AND id_ruche = :id_ruche";

if ($periode === "week") {
    $query .= " AND date_mesure >= datetime('now', '-7 days')";
} elseif ($periode === "month") {
    $query .= " AND date_mesure >= datetime('now', '-30 days')";
}

$query .= " ORDER BY date_mesure ASC";

$stmt = $conn->prepare($query);
$stmt->bindParam(":id_capteur", $id_capteur, PDO::PARAM_INT);
$stmt->bindParam(":id_ruche", $id_ruche, PDO::PARAM_INT);
$stmt->execute();
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (!$result) {
    echo json_encode(["error" => "Aucune donnée trouvée"]);
    exit();
}

echo json_encode([
    "dates" => array_column($result, "date_mesure"),
    "valeurs" => array_column($result, "valeur")
]);
?>
