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

QVariantList dataManager::getRucheData(int id_ruche)
{
    QVariantList capteursList;
    if (!db.isOpen()) {
        connectDB();
    }
    QString queryString = R"(
        SELECT c.id_capteur, c.type, c.localisation, c.description, d.valeur, d.date_mesure
        FROM capteurs c
        LEFT JOIN donnees d ON c.id_capteur = d.id_capteur
        WHERE d.id_ruche = :id_ruche AND d.date_mesure = (
            SELECT MAX(d2.date_mesure) FROM donnees d2
            WHERE d2.id_capteur = c.id_capteur AND d2.id_ruche = :id_ruche
        )
        ORDER BY c.id_capteur;
    )";
    QSqlQuery query;
    query.prepare(queryString);
    query.bindValue(":id_ruche", id_ruche);
    if (!query.exec()) {
        qDebug() << "Erreur lors de la récupération des données de la ruche:" << query.lastError().text();
        return capteursList;
    }
    while (query.next()) {
        QVariantMap capteur;
        capteur["id_capteur"] = query.value("id_capteur").toInt();
        capteur["type"] = query.value("type").toString();
        capteur["localisation"] = query.value("localisation").toString();
        capteur["description"] = query.value("description").toString();
        capteur["valeur"] = query.value("valeur").toFloat();
        capteur["date_mesure"] = query.value("date_mesure").toString();
        capteursList.append(capteur);
    }
    return capteursList;
}

QVariantList dataManager::getCapteurGraphData(int id_ruche, int id_capteur)
{
    QVariantList graphData;

    if (!db.isOpen()) {
        connectDB();
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
        SELECT d.id_donnee, r.name as ruche_name, c.type, d.valeur, d.date_mesure
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
        float valeur = query.value("valeur").toFloat();
        QString dateMesure = query.value("date_mesure").toString();
        if (!type.isEmpty() && !dateMesure.isEmpty()) {
            donnee["id_donnee"] = idDonnee;
            donnee["ruche_name"] = rucheName;
            donnee["type"] = type;
            donnee["valeur"] = valeur;
            donnee["date_mesure"] = dateMesure;
            allDataList.append(donnee);
        }
    }
    return allDataList;
}

int dataManager::addCapteur(int rucheId, const QString &type, const QString &localisation, const QString &description)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO capteurs (type, localisation, description) VALUES (:type, :localisation, :description)");
    query.bindValue(":type", type);
    query.bindValue(":localisation", localisation);
    query.bindValue(":description", description);

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'ajout du capteur:" << query.lastError().text();
        return -1;
    }

    int capteurId = query.lastInsertId().toInt();
    QDateTime now = QDateTime::currentDateTime();
    QSqlQuery dataQuery;
    dataQuery.prepare("INSERT INTO donnees (id_capteur, id_ruche, valeur, date_mesure) VALUES (:id_capteur, :id_ruche, :valeur, :date_mesure)");
    dataQuery.bindValue(":id_capteur", capteurId);
    dataQuery.bindValue(":id_ruche", rucheId);
    dataQuery.bindValue(":valeur", 0.0);
    dataQuery.bindValue(":date_mesure", now.toString("yyyy-MM-dd HH:mm:ss"));

    if (!dataQuery.exec()) {
        qDebug() << "Erreur lors de l'ajout de la mesure initiale:" << dataQuery.lastError().text();
        QSqlQuery deleteQuery;
        deleteQuery.prepare("DELETE FROM capteurs WHERE id_capteur = :id_capteur");
        deleteQuery.bindValue(":id_capteur", capteurId);
        deleteQuery.exec();

        return -1;
    }

    return capteurId;
}

bool dataManager::deleteCapteur(int capteurId)
{
    if (!db.isOpen()) {
        connectDB();
    }

    if (!db.transaction()) {
        qDebug() << "Erreur lors du démarrage de la transaction:" << db.lastError().text();
        return false;
    }
    QSqlQuery deleteDataQuery;
    deleteDataQuery.prepare("DELETE FROM donnees WHERE id_capteur = :id_capteur");
    deleteDataQuery.bindValue(":id_capteur", capteurId);
    if (!deleteDataQuery.exec()) {
        qDebug() << "Erreur lors de la suppression des données du capteur:" << deleteDataQuery.lastError().text();
        db.rollback();
        return false;
    }
    QSqlQuery deleteCapteurQuery;
    deleteCapteurQuery.prepare("DELETE FROM capteurs WHERE id_capteur = :id_capteur");
    deleteCapteurQuery.bindValue(":id_capteur", capteurId);
    if (!deleteCapteurQuery.exec()) {
        qDebug() << "Erreur lors de la suppression du capteur:" << deleteCapteurQuery.lastError().text();
        db.rollback();
        return false;
    }
    if (!db.commit()) {
        qDebug() << "Erreur lors de la validation de la transaction:" << db.lastError().text();
        db.rollback();
        return false;
    }

    return true;
}
