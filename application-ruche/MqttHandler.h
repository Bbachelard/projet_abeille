#ifndef MQTTHANDLER_H
#define MQTTHANDLER_H
#include <QCoreApplication>
#include <QAbstractItemModel>
#include <QtMqtt/QMqttClient>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>
#include <QtGui>

#include "configurateurruche.h"
#include "datamanager.h"

class MqttHandler : public QObject
{
    Q_OBJECT

public:
    explicit MqttHandler(configurateurRuche *configurateur, dataManager *dManager, QObject *parent = nullptr);
    Q_INVOKABLE void connectToBroker();
    Q_INVOKABLE QString getLastJson() const { return lastJson; }
    Q_INVOKABLE void sendMqttMessage(const QString &deviceId, const QByteArray &payload,
                                     const QString &port = "1", bool confirmed = false);
private:
    dataManager *dbManager;
    QMqttClient *mqttClient;
    QString lastJson;
    configurateurRuche *configurateur;

private slots:
    void onConnected();
    void onMessageReceived(const QByteArray &message, const QMqttTopicName &topic);

signals:
    void batteryUpdated(int rucheId, double batteryLevel);
    void messageSent(bool success, const QString &deviceId, const QString &message);

};

#endif // MQTTHANDLER_H
