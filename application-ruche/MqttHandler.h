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

class MqttHandler : public QObject
{
    Q_OBJECT

public:
    MqttHandler(configurateurRuche *configurateur,QObject *parent = nullptr);
    Q_INVOKABLE void connectToBroker();
    Q_INVOKABLE QString getLastJson() const { return lastJson; }

private:
    QMqttClient *mqttClient;
    QString lastJson;
    configurateurRuche *configurateur;

private slots:
    void onConnected();
    void onMessageReceived(const QByteArray &message, const QMqttTopicName &topic);

};

#endif // MQTTHANDLER_H
