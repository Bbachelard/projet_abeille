<?php
$database = "/home/pi/nom_base.sqlite3";
try {
    $conn = new PDO("sqlite:$database");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connexion à la base de données réussie!";
    
    // Liste les tables pour vérifier
    $result = $conn->query("SELECT name FROM sqlite_master WHERE type='table';");
    echo "<br>Tables dans la base de données :<br>";
    while($row = $result->fetch(PDO::FETCH_ASSOC)) {
        echo $row['name'] . "<br>";
    }
} catch (PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
?>
