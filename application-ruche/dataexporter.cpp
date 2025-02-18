#include "dataexporter.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>


dataExporter::dataExporter(QObject *parent) : QObject(parent) {
}
void dataExporter::saveData(int id_capteur, float valeur, QDateTime date_mesure)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    db.setHostName("172.21.28.77");
    db.setDatabaseName("ruche_connectee");
    db.setUserName("root");
    db.setPassword("ruche1234");

    if (!db.open()) {
        qDebug() << "Impossible de se connecter à la base de données!";
        return;
    }
    qDebug() << "Données envoyées : capteur=" << id_capteur << ", valeur=" << valeur << ", date=" << date_mesure.toString("yyyy-MM-dd HH:mm:ss");

    QSqlQuery query;
    query.prepare("INSERT INTO donnees (id_capteur, valeur, date_mesure) VALUES (:id_capteur, :valeur, :date_mesure)");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":valeur", valeur);
    query.bindValue(":date_mesure", date_mesure);

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'insertion des données :" << query.lastError().text();
    } else {
        qDebug() << "Donnée insérée avec succès !";
    }

    db.close();
}

