#include "ruche.h"

Ruche::Ruche(QObject *parent)
    : QObject(parent),m_batterie(100.0),
    m_id(-1),
    m_name("Nouvelle Ruche"),
    m_mqttAdresse(""),
    m_temperature(0.0),
    m_humidity(0.0),
    m_mass(0.0),
    m_pressure(0.0),
    m_imagePath("qrc:/placeholder.png")
{
    m_lastUpdate = QDateTime::currentDateTime();
}

Ruche* Ruche::createTestRuche()
{
    Ruche* ruche = new Ruche();
    ruche->setId(1);
    ruche->setName("Ruche Test");
    ruche->setData(22.5, 65.8, 25.0, 1013.2, "qrc:/placeholder.png", QDateTime::currentDateTime());
    return ruche;
}

void Ruche::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Ruche::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void Ruche::setMqttAdresse(const QString &adresse)
{
    if (m_mqttAdresse != adresse) {
        m_mqttAdresse = adresse;
        emit mqttAdresseChanged();
    }
}

void Ruche::setData(float temperature, float humidity, float mass, float pressure,
                    const QString &imagePath, const QDateTime &timestamp)
{
    bool dataChanged = false;

    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
        dataChanged = true;
    }

    if (m_humidity != humidity) {
        m_humidity = humidity;
        emit humidityChanged();
        dataChanged = true;
    }

    if (m_mass != mass) {
        m_mass = mass;
        emit massChanged();
        dataChanged = true;
    }

    if (m_pressure != pressure) {
        m_pressure = pressure;
        emit pressureChanged();
        dataChanged = true;
    }

    if (m_imagePath != imagePath) {
        m_imagePath = imagePath;
        emit imagePathChanged();
        dataChanged = true;
    }

    if (m_lastUpdate != timestamp) {
        m_lastUpdate = timestamp;
        emit lastUpdateChanged();
        dataChanged = true;
    }
    if (dataChanged) {
        qDebug() << "Données de la ruche" << m_id << "mises à jour:"
                 << "Temp:" << m_temperature
                 << "Humidité:" << m_humidity
                 << "Poids:" << m_mass
                 << "Pression:" << m_pressure;
    }
}


