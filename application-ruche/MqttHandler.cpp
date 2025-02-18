#include "MqttHandler.h"

MqttHandler::MqttHandler(configurateurRuche *configurateur,QObject *parent)
    : QObject(parent), configurateur(configurateur)
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

        if (!rxMetadata.isEmpty()) {
            QJsonObject location = rxMetadata.first().toObject()["location"].toObject();
            double latitude = location["latitude"].toDouble();
            double longitude = location["longitude"].toDouble();
            float temperature=18;
            float humidity=20;
            float mass=10;
            float pression=10;
            QString imgPath="qrc:/img.png";

            qDebug() << "Date de réception :" << receivedAt;
            qDebug() << "Latitude :" << latitude;
            qDebug() << "Longitude :" << longitude;

            QList<Ruche*> ruchesList = configurateur->getRuchesList();
            if (ruchesList.isEmpty()) {
                qDebug() << "Aucune ruche trouvée, création d'une nouvelle ruche.";
                configurateur->addRuche(Ruche::createTestRuche());
            } else {
                qDebug() << "Ruche déjà existante, mise à jour uniquement.";
            }
            receivedAt = receivedAt.left(23) + "Z";  // On garde jusqu'aux millisecondes
            QDateTime receivedDateTime = QDateTime::fromString(receivedAt, Qt::ISODateWithMs);

            ruchesList = configurateur->getRuchesList();
            for (Ruche* ruche : ruchesList) {
                if (ruche->getId() == 0) {
                    qDebug() << "Mise à jour de la ruche avec l'ID 1";
                    ruche->setData(temperature, humidity, mass, pression, imgPath, receivedDateTime);
                    break;
                }else
                    qDebug()<<"pas trouver!!!!!";
            }

        } else {
            qDebug() << "Pas de métadonnées de localisation.";
        }
    } else {
        qDebug() << "Erreur lors de la conversion du message en JSON.";
    }
}
