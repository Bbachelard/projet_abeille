#include "datamanager.h"

void dataManager::saveData(int id_ruche, int id_capteur, float valeur, QDateTime date_mesure)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO donnees (id_capteur, id_ruche, valeur, date_mesure) VALUES (:id_capteur, :id_ruche, :valeur, :date_mesure)");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":id_ruche", id_ruche);
    query.bindValue(":valeur", valeur);
    query.bindValue(":date_mesure", date_mesure.toString("yyyy-MM-dd HH:mm:ss"));

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'insertion des données:" << query.lastError().text();
    }
}


QVariantList dataManager::getCapteurGraphData(int id_ruche, int id_capteur)
{
    QVariantList graphData;

    if (!db.isOpen()) {
        connectDB();
    }
    QSqlQuery measureQuery;
    measureQuery.prepare("SELECT mesure FROM capteurs WHERE id_capteur = :id_capteur");
    measureQuery.bindValue(":id_capteur", id_capteur);
    QString uniteMesure;

    if (measureQuery.exec() && measureQuery.next()) {
        uniteMesure = measureQuery.value("mesure").toString();
    }
    QSqlQuery query;
    query.prepare("SELECT valeur, date_mesure FROM donnees WHERE id_capteur = :id_capteur AND id_ruche = :id_ruche ORDER BY date_mesure ASC");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":id_ruche", id_ruche);
    if (!query.exec()) {
        qDebug() << "Erreur lors de la récupération des données graphiques:" << query.lastError().text();
        return graphData;
    }

    while (query.next()) {
        QVariantMap point;
        point["valeur"] = query.value("valeur").toFloat();
        point["date_mesure"] = query.value("date_mesure").toString();
        point["unite_mesure"] = uniteMesure;
        graphData.append(point);
    }

    return graphData;
}

QVariantList dataManager::getAllRucheData()
{
    QVariantList allDataList;
    if (!db.isOpen()) {
        connectDB();
    }
    QString queryString = R"(
        SELECT d.id_donnee, r.name as ruche_name, c.type, c.mesure, d.valeur, d.date_mesure
        FROM capteurs c
        INNER JOIN donnees d ON c.id_capteur = d.id_capteur
        INNER JOIN ruche r ON d.id_ruche = r.id_ruche
        ORDER BY d.date_mesure DESC, r.name ASC, c.type ASC;
    )";
    QSqlQuery query;
    if (!query.exec(queryString)) {
        qDebug() << "Erreur lors de la récupération de toutes les données:" << query.lastError().text();
        return allDataList;
    }
    while (query.next()) {
        QVariantMap donnee;
        int idDonnee = query.value("id_donnee").toInt();
        QString rucheName = query.value("ruche_name").toString();
        QString type = query.value("type").toString();
        QString mesure = query.value("mesure").toString();
        float valeur = query.value("valeur").toFloat();
        QString dateMesure = query.value("date_mesure").toString();
        if (!type.isEmpty() && !dateMesure.isEmpty()) {
            donnee["id_donnee"] = idDonnee;
            donnee["ruche_name"] = rucheName;
            donnee["type"] = type;
            donnee["mesure"] = mesure;
            donnee["valeur"] = valeur;
            donnee["date_mesure"] = dateMesure;
            allDataList.append(donnee);
        }
    }
    return allDataList;
}
