#include "MqttHandler.h"

MqttHandler::MqttHandler(configurateurRuche *configurateur,dataManager *dManager,QObject *parent)
    : QObject(parent), configurateur(configurateur),dbManager(dManager)
{
    mqttClient = new QMqttClient(this);
    mqttClient->setHostname("eu1.cloud.thethings.network");
    mqttClient->setPort(1883);
    mqttClient->setUsername("tp-lorawan-2024@ttn");
    mqttClient->setPassword("NNSXS.W5MQRIQ2A6RHPW2BVP5UY2AJPBWBE2JWYGP3H5I.K22BTAB4BZBKMLKWGSQ34DYBARPTTXIMBK2IG2DBZRYGVRKPE3MQ");

    connect(mqttClient, &QMqttClient::connected, this, &MqttHandler::onConnected);
    connect(mqttClient, &QMqttClient::messageReceived, this, &MqttHandler::onMessageReceived);
}

void MqttHandler::connectToBroker()
{
    mqttClient->connectToHost();
}



void MqttHandler::onConnected()
{
    qDebug() << "Connected to MQTT broker";
    mqttClient->subscribe(QMqttTopicFilter("v3/tp-lorawan-2024@ttn/devices/#"));

}

void MqttHandler::onMessageReceived(const QByteArray &message, const QMqttTopicName &topic)
{
    qDebug() << "Message reçu sur le topic :" << topic.name();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(message);
    if (!jsonDoc.isNull() && jsonDoc.isObject()) {
        QJsonObject jsonObj = jsonDoc.object();
        QString receivedAt = jsonObj.value("received_at").toString();
        QJsonArray rxMetadata = jsonObj["uplink_message"].toObject()["rx_metadata"].toArray();

        double batteryLevel = 100.0; // Valeur par défaut

        if (jsonObj.contains("uplink_message") && jsonObj["uplink_message"].isObject()) {
            QJsonObject uplinkMsg = jsonObj["uplink_message"].toObject();

            if (uplinkMsg.contains("battery") && uplinkMsg["battery"].isDouble()) {
                batteryLevel = uplinkMsg["battery"].toDouble();
            }
            else if (uplinkMsg.contains("decoded_payload") && uplinkMsg["decoded_payload"].isObject()) {
                QJsonObject payload = uplinkMsg["decoded_payload"].toObject();
                if (payload.contains("battery") && payload["battery"].isDouble()) {
                    batteryLevel = payload["battery"].toDouble();
                }
                else if (payload.contains("battery_voltage") && payload["battery_voltage"].isDouble()) {
                    double voltage = payload["battery_voltage"].toDouble();
                    batteryLevel = qBound(0.0, ((voltage - 3.0) / 1.2) * 100.0, 100.0);
                }
            }
        }

        qDebug() << "Niveau de batterie détecté:" << batteryLevel << "%";
        if (!rxMetadata.isEmpty()) {
            float temperature = 18;
            float humidity = 20;
            float mass = 10;
            float pressure = 10;
            QString imgPath = "qrc:/img.png";
            qDebug() << "Date de réception :" << receivedAt;
            receivedAt = receivedAt.left(23) + "Z";
            QDateTime receivedDateTime = QDateTime::fromString(receivedAt, Qt::ISODateWithMs);
            QString topicName = topic.name();
            QString rucheName = "Ruche";
            if (topicName.contains("/devices/")) {
                QStringList parts = topicName.split("/devices/");
                if (parts.size() > 1) {
                    rucheName = parts[1].split("/")[0];
                }
            }
            int rucheId = dbManager->addOrUpdateRuche(rucheName, topicName, batteryLevel);
            if (rucheId < 0) {
                qDebug() << "❌ Erreur lors de l'ajout de la ruche dans la base de données";
                return;
            }

            Ruche* cibleRuche = configurateur->getRucheById(rucheId);
            if (!cibleRuche) {
                qDebug() << "✅ Création d'une nouvelle instance de ruche dans le configurateur";
                cibleRuche = new Ruche();
                cibleRuche->setId(rucheId);
                cibleRuche->setName(rucheName);
                cibleRuche->setMqttAdresse(topicName);
                cibleRuche->setBatterie(batteryLevel);
                configurateur->addRuche(cibleRuche);
            } else {
                cibleRuche->setBatterie(batteryLevel);
            }
            cibleRuche->setData(temperature, humidity, mass, pressure, imgPath, receivedDateTime);
            dbManager->saveData(rucheId, 1, temperature, receivedDateTime);
            dbManager->saveData(rucheId, 2, humidity, receivedDateTime);
            dbManager->saveData(rucheId, 3, mass, receivedDateTime);
            dbManager->saveData(rucheId, 4, pressure, receivedDateTime);
            emit batteryUpdated(rucheId, batteryLevel);
        } else {
            qDebug() << "Pas de métadonnées de localisation.";
        }
    } else {
        qDebug() << "Erreur lors de la conversion du message en JSON.";
    }
}
