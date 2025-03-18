
// 1. Animation des abeilles en SVG
document.addEventListener("DOMContentLoaded", () => {
    const bees = document.querySelectorAll(".bee");
    bees.forEach(bee => {
        bee.animate([
            { transform: "translateY(0px)" },
            { transform: "translateY(5px)" },
            { transform: "translateY(-5px)" },
            { transform: "translateY(0px)" }
        ], {
            duration: 3000,
            iterations: Infinity
        });
    });
});

// 2. Compteur en direct du nombre de capteurs actifs
function updateSensorCount() {
    fetch("/api/sensors/active") // Adapte l'URL selon ton API
        .then(response => response.json())
        .then(data => {
            document.getElementById("sensor-count").textContent = data.active;
        })
        .catch(error => console.error("Erreur lors de la récupération des capteurs", error));
}
setInterval(updateSensorCount, 5000); // Mise à jour toutes les 5 secondes

// 3. Notifications dynamiques si une valeur critique est atteinte
function checkCriticalValues() {
    fetch("/api/sensors/data") // Adapte l'URL selon ton API
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
setInterval(checkCriticalValues, 10000);

// Fonction pour afficher une notification
function showNotification(message, type) {
    const notification = document.createElement("div");
    notification.className = `notification ${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => notification.remove(), 5000);
}

