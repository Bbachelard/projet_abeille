#ifndef RUCHE_H
#define RUCHE_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QVector>
#include <QVariant>
#include <QDebug>
#include "data.h"

class Ruche : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ getId WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString mqttAdresse READ getMqttAdresse WRITE setMqttAdresse NOTIFY mqttAdresseChanged)
    Q_PROPERTY(float temperature READ getTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(float humidity READ getHumidity NOTIFY humidityChanged)
    Q_PROPERTY(float mass READ getMass NOTIFY massChanged)
    Q_PROPERTY(float pressure READ getPressure NOTIFY pressureChanged)
    Q_PROPERTY(QString imagePath READ getImagePath NOTIFY imagePathChanged)
    Q_PROPERTY(QDateTime lastUpdate READ getLastUpdate NOTIFY lastUpdateChanged)


public:
    explicit Ruche(QObject *parent = nullptr);

    int getId() const { return m_id; }
    double getBatterie() const { return m_batterie; }
    void setId(int id);
    void setBatterie(double value) { m_batterie = value; }

    QString getName() const { return m_name; }
    void setName(const QString &name);

    QString getMqttAdresse() const { return m_mqttAdresse; }
    void setMqttAdresse(const QString &adresse);

    float getTemperature() const { return m_temperature; }
    float getHumidity() const { return m_humidity; }
    float getMass() const { return m_mass; }
    float getPressure() const { return m_pressure; }
    QString getImagePath() const { return m_imagePath; }
    QDateTime getLastUpdate() const { return m_lastUpdate; }

    void setData(float temperature, float humidity, float mass, float pressure,const QString &imagePath, const QDateTime &timestamp);
    static Ruche* createTestRuche();

signals:
    void idChanged();
    void nameChanged();
    void mqttAdresseChanged();
    void temperatureChanged();
    void humidityChanged();
    void massChanged();
    void pressureChanged();
    void imagePathChanged();
    void lastUpdateChanged();

private:
    int m_id;
    QString m_name;
    QString m_mqttAdresse;
    float m_temperature;
    float m_humidity;
    float m_mass;
    float m_pressure;
    QString m_imagePath;
    QDateTime m_lastUpdate;
    double m_batterie;
};
#endif // RUCHE_H
