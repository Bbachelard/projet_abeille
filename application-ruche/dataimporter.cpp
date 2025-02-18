#include "dataimporter.h"

Dataimporter::Dataimporter() {}


Data Dataimporter::retrieveData()
{/*
    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    db.setHostName("localhost");
    db.setDatabaseName("ruche_db");
    db.setUserName("root");
    db.setPassword("password");

    Data data;

    if (!db.open()) {
        qDebug() << "Impossible de se connecter à la base de données!";
        return data;
    }

    QSqlQuery query("SELECT * FROM mesures ORDER BY dateTime DESC LIMIT 1");

    if (query.next()) {
        data.temperature = query.value("temperature").toFloat();
        data.humidity = query.value("humidity").toFloat();
        data.mass = query.value("mass").toFloat();
        data.pression = query.value("pressure").toFloat();
        data.imgPath = query.value("imgPath").toString();
        data.dateTime = QDateTime::fromString(query.value("dateTime").toString(), "yyyy-MM-dd HH:mm:ss");
    }

    db.close();
    return data;*/
}
