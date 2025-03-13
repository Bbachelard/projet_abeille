#include "ruche.h"

int Ruche::nextId = 0;

Ruche::Ruche(QObject *parent,const QString &mqttAdresse) : QObject(parent), id(nextId++),mqttAdresse(mqttAdresse)
{
}

void Ruche::setData(float m_temp, float m_hum, float m_mass, float m_pression, QString m_imgPath, QDateTime m_dateTime)
{
        Data newData;
        newData.temperature = m_temp;
        newData.humidity = m_hum;
        newData.mass = m_mass;
        newData.pression = m_pression;
        newData.imgPath = m_imgPath;
        newData.dateTime = m_dateTime;
        dataList.append(newData);
/*
        qDebug() << "Nouvelle donnée ajoutée - Temp:" << newData.temperature
                 << "Humidité:" << newData.humidity
                 << "Masse:" << newData.mass
                 << "Pression:" << newData.pression
                 << "DateTime:" << newData.dateTime.toString(Qt::ISODate);

        qDebug() << "Nombre total d'entrées dans dataList :" << dataList.size();*/
        emit dataListChanged();
}

QVariantList Ruche::getDataList() const {
    QVariantList list;
    for (const Data &d : dataList) {
        QVariantMap map;
        map["temperature"] = d.temperature;
        map["humidity"] = d.humidity;
        map["mass"] = d.mass;
        map["pression"] = d.pression;
        map["imgPath"] = d.imgPath;
        map["dateTime"] = d.dateTime.toString("yyyy-MM-dd HH:mm:ss");
        list.append(map);
    }
    return list;
}

int Ruche::getId()const
{
    return id;
}


Ruche *Ruche::createTestRuche()
{
    Ruche *testRuche = new Ruche();
    QDateTime testDateTime = QDateTime::currentDateTime();
    // Données fictives pour la ruche
    testRuche->setData(25.0, 50.0, 10.5, 1013.0, "qrc:/images/testImage.png", testDateTime);

    return testRuche;
}

QString Ruche::getMqttAdresse() const {
    return mqttAdresse;
}
void Ruche::setMqttAdresse(const QString &adresse) {
    if (mqttAdresse != adresse) {
        mqttAdresse = adresse;
        emit mqttAdresseChanged();
    }
}
