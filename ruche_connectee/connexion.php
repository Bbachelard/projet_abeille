<?php
// connexion.php

$servername = "localhost";  
$username = "naxio";       
$password = "NaXiolot63_"; 
$dbname = "ruche_connectee";  

// Connexion MySQL (commenté)
 $conn = new mysqli($servername, $username, $password, $dbname);
 if ($conn->connect_error) {
     die("Connection failed: " . $conn->connect_error);
 }
 

?>