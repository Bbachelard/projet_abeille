// Met à jour le compteur des capteurs actifs
function updateSensorCount() {
    fetch("/api.php?request=sensors/active")
        .then(response => response.json())
        .then(data => {
            document.getElementById("sensor-count").textContent = data.active;
        })
        .catch(error => console.error("Erreur récupération capteurs", error));
}

// Vérifie les valeurs critiques des capteurs
function checkCriticalValues() {
    fetch("/api.php?request=sensors/data")
        .then(response => response.json())
        .then(data => {
            data.sensors.forEach(sensor => {
                if (sensor.temperature < 10) {
                    showNotification(`Température trop basse : ${sensor.temperature}°C`, "warning");
                }
                if (sensor.humidity > 90) {
                    showNotification(`Humidité trop élevée : ${sensor.humidity}%`, "danger");
                }
            });
        })
        .catch(error => console.error("Erreur récupération données", error));
}

// Affiche une notification
function showNotification(message, type) {
    const notification = document.createElement("div");
    notification.className = `notification ${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => notification.remove(), 5000);
}

// Rafraîchir les données toutes les X secondes
setInterval(updateSensorCount, 5000);
setInterval(checkCriticalValues, 10000);
