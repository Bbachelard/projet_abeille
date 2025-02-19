<?php
include 'connexion.php';

$capteur = $_GET['capteur'] ?? '';

$capteur_id_map = [
    'temperature' => 1,
    'humidite' => 2,
    'masse' => 4
];

if (!isset($capteur_id_map[$capteur])) {
    echo json_encode(["error" => "Capteur non trouvé"]);
    exit;
}

$id_capteur = $capteur_id_map[$capteur];

$query = "SELECT valeur, date_mesure FROM donnees WHERE id_capteur = ? ORDER BY date_mesure ASC";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id_capteur);
$stmt->execute();
$result = $stmt->get_result();

$data = ["dates" => [], "valeurs" => []];

while ($row = $result->fetch_assoc()) {
    $data["dates"][] = $row["date_mesure"];
    $data["valeurs"][] = $row["valeur"];
}

echo json_encode($data);
?>
