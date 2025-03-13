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

        if (!rxMetadata.isEmpty()) {
            float temperature=18;
            float humidity=20;
            float mass=10;
            float pression=10;
            QString imgPath="qrc:/img.png";

            qDebug() << "Date de réception :" << receivedAt;
            receivedAt = receivedAt.left(23) + "Z";
            QDateTime receivedDateTime = QDateTime::fromString(receivedAt, Qt::ISODateWithMs);


            QList<Ruche*> ruchesList = configurateur->getRuchesList();
            Ruche* cibleRuche = nullptr;
            for (Ruche* ruche : ruchesList) {
                if (ruche->getMqttAdresse() == topic.name()) {
                    cibleRuche = ruche;
                    break;
                }
            }
            if (!cibleRuche) {
                qDebug() << "⚠️ Aucune ruche ne correspond à ce topic, création d'une nouvelle.";
                cibleRuche = Ruche::createTestRuche();
                cibleRuche->setMqttAdresse(topic.name());
                configurateur->addRuche(cibleRuche);
            } else {
                qDebug() << "✅ Ruche trouvée avec MQTT Adresse : " << cibleRuche->getMqttAdresse();
            }


            cibleRuche->setData(temperature, humidity, mass, pression, imgPath, receivedDateTime);

            // Enregistrement des données en base avec l'ID de la ruche
            int rucheId = cibleRuche->getId();
            dbManager->saveData(rucheId * 10 + 1, temperature, receivedDateTime);
            dbManager->saveData(rucheId * 10 + 2, humidity, receivedDateTime);
            dbManager->saveData(rucheId * 10 + 3, mass, receivedDateTime);
            dbManager->saveData(rucheId * 10 + 4, pression, receivedDateTime);

        } else {
            qDebug() << "Pas de métadonnées de localisation.";
        }
    } else {
        qDebug() << "Erreur lors de la conversion du message en JSON.";
    }
}
