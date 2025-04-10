<?php
$mot_de_passe = "root1234"; 
$hash = password_hash($mot_de_passe, PASSWORD_DEFAULT); 
echo "Mot de passe haché : " . $hash;
?>
