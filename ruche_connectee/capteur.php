<?php
$conn = new mysqli("localhost", "naxio", "NaXiolot63_", "ruche_connectee");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT capteurs.type, capteurs.localisation, donnees.valeur, donnees.date_mesure 
        FROM capteurs 
        JOIN donnees ON capteurs.id_capteur = donnees.id_capteur
        ORDER BY donnees.date_mesure DESC"; 
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<table border='1'><tr><th>Type de Capteur</th><th>Localisation</th><th>Valeur</th><th>Date de Mesure</th></tr>";
    while($row = $result->fetch_assoc()) {
        echo "<tr><td>" . $row["type"]. "</td><td>" . $row["localisation"]. "</td><td>" . $row["valeur"]. "</td><td>" . $row["date_mesure"]. "</td></tr>";
    }
    echo "</table>";
} else {
    echo "0 résultats";
}

$conn->close();
?>
