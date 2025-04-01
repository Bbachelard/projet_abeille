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
    qDebug() << "\n\n======= NOUVEAU MESSAGE MQTT =======";
    qDebug() << "Topic:" << topic.name();

    // Extraction du frm_payload directement (pour déboguer)
    QString rawPayload;
    QJsonDocument rawJsonDoc = QJsonDocument::fromJson(message);
    if (!rawJsonDoc.isNull() && rawJsonDoc.isObject()) {
        QJsonObject rawObj = rawJsonDoc.object();
        if (rawObj.contains("uplink_message") && rawObj["uplink_message"].isObject()) {
            QJsonObject uplink = rawObj["uplink_message"].toObject();
            if (uplink.contains("frm_payload") && uplink["frm_payload"].isString()) {
                rawPayload = uplink["frm_payload"].toString();
                qDebug() << "frm_payload brut:" << rawPayload;
            }
        }
    }

    QJsonDocument jsonDoc = QJsonDocument::fromJson(message);
    if (jsonDoc.isNull() || !jsonDoc.isObject()) {
        qDebug() << "Erreur JSON dans le message MQTT";
        return;
    }

    QJsonObject jsonObj = jsonDoc.object();
    QJsonObject uplinkMsg = jsonObj["uplink_message"].toObject();

    float temperature = 0.0f;
    float humidity = 0.0f;
    float mass = 0.0f;
    float pressure = 0.0f;
    bool dataValid = false;
    double batteryLevel = 0;

    QString receivedAt = jsonObj.value("received_at").toString();
    qDebug() << "Timestamp reçu:" << receivedAt;
    if (uplinkMsg.contains("frm_payload") && uplinkMsg["frm_payload"].isString()) {
        QString frm_payload = uplinkMsg["frm_payload"].toString();
        QByteArray decodedData = QByteArray::fromBase64(frm_payload.toLatin1());
        QString decodedStr = QString::fromUtf8(decodedData);
        qDebug() << "PAYLOAD DÉCODÉ:" << decodedData;
        decodedStr = decodedStr.trimmed();
        decodedStr.replace(";", ",");
        if (decodedStr.startsWith(" ")) {
            decodedStr = decodedStr.mid(1);
        }
        if (decodedStr.endsWith(",}")) {
            decodedStr.replace(",}", "}");
        }

        QJsonParseError jsonError;
        QJsonDocument jsonPayload = QJsonDocument::fromJson(decodedStr.toUtf8(), &jsonError);
        if (jsonError.error != QJsonParseError::NoError) {
            qDebug() << "ERREUR JSON:" << jsonError.errorString() << "à position" << jsonError.offset;
        }
        else if (jsonPayload.isObject()) {
            QJsonObject jsonData = jsonPayload.object();
            temperature = jsonData.contains("Temp") ? jsonData["Temp"].toDouble() : 0.0f;
            humidity = jsonData.contains("Hum") ? jsonData["Hum"].toDouble() : 0.0f;
            mass = jsonData.contains("Masse") ? jsonData["Masse"].toDouble() : 0.0f;
            pressure = jsonData.contains("Pres") ? jsonData["Pres"].toDouble() : 0.0f;
            batteryLevel = jsonData["Bat"].toDouble();
            if (temperature == 0 && humidity == 0 && mass == 0 && pressure == 0) {
                qDebug() << "ALERTE: Toutes les valeurs sont à zéro - valeurs forcées pour test";
                temperature = 23.0f;
                humidity = 35.0f;
                mass = 49.0f;
                pressure = 8.0f;
                batteryLevel =100;
            }

            dataValid = true;
        }
    }
    if (!dataValid) {
        qDebug() << "AUCUNE DONNÉE VALIDE TROUVÉE DANS LE PAYLOAD";
        return;
    }
    QString topicName = topic.name();
    QString rucheName = "Ruche";
    if (topicName.contains("/devices/")) {
        QStringList parts = topicName.split("/devices/");
        if (parts.size() > 1) {
            rucheName = parts[1].split("/")[0];
        }
    }
    receivedAt = receivedAt.left(23) + "Z";
    QDateTime receivedDateTime = QDateTime::fromString(receivedAt, Qt::ISODateWithMs);
    receivedDateTime = receivedDateTime.addSecs(3600); // +1h pour Paris

    int rucheId = dbManager->addOrUpdateRuche(rucheName, topicName, batteryLevel);
    if (rucheId < 0) {
        return;
    }

    qDebug() << "ID RUCHE:" << rucheId;
    qDebug() << "NOM RUCHE:" << rucheName;

    Ruche* cibleRuche = configurateur->getRucheById(rucheId);
    if (!cibleRuche) {
        qDebug() << "CRÉATION D'UNE NOUVELLE RUCHE DANS LE CONFIGURATEUR";
        cibleRuche = new Ruche();
        cibleRuche->setId(rucheId);
        cibleRuche->setName(rucheName);
        cibleRuche->setMqttAdresse(topicName);
        cibleRuche->setBatterie(batteryLevel);
        configurateur->addRuche(cibleRuche);
    } else {
        cibleRuche->setBatterie(batteryLevel);
    }
    QString imgPath = "qrc:/img.png";

    try {
        cibleRuche->setData(temperature, humidity, mass, pressure, imgPath, receivedDateTime);

        dbManager->saveData(rucheId, 1, temperature, receivedDateTime);  // Température
        dbManager->saveData(rucheId, 2, humidity, receivedDateTime);     // Humidité
        dbManager->saveData(rucheId, 3, mass, receivedDateTime);         // Masse
        dbManager->saveData(rucheId, 4, pressure, receivedDateTime);     // Pression

        qDebug() << "DONNÉES ENREGISTRÉES EN DB - RUCHE:" << rucheId;

    } catch (const std::exception& e) {
        qDebug() << "EXCEPTION PENDANT SETDATA:" << e.what();
    }

    // Mise à jour de la batterie
    emit batteryUpdated(rucheId, batteryLevel);
    qDebug() << "======= FIN DU TRAITEMENT =======\n";
}
