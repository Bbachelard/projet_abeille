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
            temperature = jsonData.contains("T") ? jsonData["T"].toDouble() : 0.0f;
            humidity = jsonData.contains("H") ? jsonData["H"].toDouble() : 0.0f;
            mass = jsonData.contains("M") ? jsonData["M"].toDouble() : 0.0f;
            pressure = jsonData.contains("P") ? jsonData["P"].toDouble() : 0.0f;
            batteryLevel = jsonData.contains("Bat") ? jsonData["Bat"].toDouble() : 0.0f;
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
        dbManager->updateRucheBatterie(rucheId, batteryLevel);
        qDebug() << "DONNÉES ENREGISTRÉES EN DB - RUCHE:" << rucheId;

    } catch (const std::exception& e) {
        qDebug() << "EXCEPTION PENDANT SETDATA:" << e.what();
    }

    // Mise à jour de la batterie
    emit batteryUpdated(rucheId, batteryLevel);
    qDebug() << "======= FIN DU TRAITEMENT =======\n";
}


void MqttHandler::sendMqttMessage(const QString &deviceId, const QByteArray &payload,
                                  const QString &port, bool confirmed)
{
    // Construction du topic pour l'envoi de messages downlink
    // Format: v3/{application-id}@{tenant-id}/devices/{device-id}/down/push
    QString topic = QString("v3/tp-lorawan-2024@ttn/devices/%1/down/push").arg(deviceId);

    // Création du message JSON pour la requête downlink
    QJsonObject messageObj;

    // Construire l'objet "downlinks"
    QJsonObject downlinkObj;

    // Encoder le payload en base64
    QString base64Payload = QString::fromLatin1(payload.toBase64());
    downlinkObj["frm_payload"] = base64Payload;
    downlinkObj["f_port"] = port;

    // Si le message est confirmé, ajouter le champ confirmed
    if (confirmed) {
        downlinkObj["confirmed"] = true;
    }

    // Ajouter l'objet downlink au tableau "downlinks"
    QJsonArray downlinksArray;
    downlinksArray.append(downlinkObj);
    messageObj["downlinks"] = downlinksArray;

    // Convertir l'objet JSON en chaîne
    QJsonDocument doc(messageObj);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);
    qDebug() << "Envoi de message MQTT sur le topic:" << topic;
    qDebug() << "Payload:" << jsonData;

    // Publier le message
    qint32 publishResult = mqttClient->publish(
        QMqttTopicName(topic),
        jsonData,
        0,  // QoS 0
        false // Retain
    );

    bool success = (publishResult != -1);
    emit messageSent(success, deviceId, QString::fromUtf8(payload));

    if (success) {
        qDebug() << "Message MQTT envoyé avec succès à" << deviceId;
    } else {
        qDebug() << "Échec de l'envoi du message MQTT à" << deviceId;
    }
}
