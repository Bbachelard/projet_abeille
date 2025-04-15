#include "SensorDataManager.h"

SensorDataManager::SensorDataManager(QObject *parent) : dataManager(parent)
{
    // Initialisation spécifique pour SensorDataManager
}

void SensorDataManager::saveData(int id_ruche, int id_capteur, float valeur, QDateTime date_mesure)
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


QVariantList SensorDataManager::getCapteurGraphData(int id_ruche, int id_capteur)
{
    QVariantList graphData;

    if (!db.isOpen()) {
        connectDB();
    }

    // Récupérer l'unité de mesure du capteur
    QSqlQuery measureQuery;
    measureQuery.prepare("SELECT mesure FROM capteurs WHERE id_capteur = :id_capteur");
    measureQuery.bindValue(":id_capteur", id_capteur);
    QString uniteMesure;

    if (measureQuery.exec() && measureQuery.next()) {
        uniteMesure = measureQuery.value("mesure").toString();
    }

    // Récupérer les données du capteur
    QSqlQuery query;
    query.prepare("SELECT valeur, date_mesure FROM donnees WHERE id_capteur = :id_capteur AND id_ruche = :id_ruche ORDER BY date_mesure ASC");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":id_ruche", id_ruche);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la récupération des données graphiques:" << query.lastError().text();
        return graphData;
    }

    // Remplir graphData avec les résultats
    while (query.next()) {
        QVariantMap point;
        point["valeur"] = query.value("valeur").toFloat();
        point["date_mesure"] = query.value("date_mesure").toString();
        point["unite_mesure"] = uniteMesure;
        graphData.append(point);
    }

    // Calcul des dates min/max si des données existent
    QDateTime minDate, maxDate;
    if (graphData.size() > 0) {
        QString firstDateStr = graphData.first().toMap()["date_mesure"].toString();
        QString lastDateStr = graphData.last().toMap()["date_mesure"].toString();
        minDate = QDateTime::fromString(firstDateStr, "yyyy-MM-dd HH:mm:ss");
        maxDate = QDateTime::fromString(lastDateStr, "yyyy-MM-dd HH:mm:ss");
    }

    // Déterminer le type de capteur
    QString capteurType = "Capteur";
    QSqlQuery typeQuery;
    typeQuery.prepare("SELECT type FROM capteurs WHERE id_capteur = :id_capteur");
    typeQuery.bindValue(":id_capteur", id_capteur);
    if (typeQuery.exec() && typeQuery.next()) {
        capteurType = typeQuery.value("type").toString();
    }

    // Afficher un log pour le débogage
    qDebug() << "getCapteurGraphData: Récupération de" << graphData.size() << "points de données pour le capteur" << id_capteur << "(" << capteurType << ")";

    // Émettre le signal pour le QML
    emit chartDataLoaded(graphData, minDate, maxDate, capteurType, false);

    return graphData;
}

QVariantList SensorDataManager::getAllRucheData()
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


QVariantList SensorDataManager::getLastCapteurValue(int id_capteur, int id_ruche)
{
    QVariantList result;
    if (!db.isOpen()) {
        connectDB();
    }
    // D'abord, récupérer les informations sur le capteur pour obtenir l'unité de mesure
    QSqlQuery capteurQuery;
    capteurQuery.prepare("SELECT type, mesure FROM capteurs WHERE id_capteur = :id_capteur");
    capteurQuery.bindValue(":id_capteur", id_capteur);
    QString type;
    QString uniteMesure;
    if (capteurQuery.exec() && capteurQuery.next()) {
        type = capteurQuery.value("type").toString();
        uniteMesure = capteurQuery.value("mesure").toString();
    } else {
        qDebug() << "Erreur lors de la récupération des informations du capteur:" << capteurQuery.lastError().text();
        return result;
    }
    // Ensuite, récupérer la dernière valeur mesurée
    QSqlQuery query;
    query.prepare("SELECT valeur, date_mesure FROM donnees WHERE id_capteur = :id_capteur AND id_ruche = :id_ruche ORDER BY date_mesure DESC LIMIT 1");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":id_ruche", id_ruche);

    if (query.exec() && query.next()) {
        float valeur = query.value("valeur").toFloat();
        QString dateMesure = query.value("date_mesure").toString();
        QDateTime dateTime = QDateTime::fromString(dateMesure, "yyyy-MM-dd HH:mm:ss");
        QString dateFormatee;
        if (dateTime.isValid()) {
            dateFormatee = dateTime.toString("dd/MM/yyyy HH:mm");
        } else {
            dateFormatee = dateMesure;
        }

        // Créer un QVariantMap pour chaque élément de résultat et l'ajouter à la liste
        QVariantMap item;
        item["success"] = true;
        item["valeur"] = valeur;
        item["date_mesure"] = dateMesure;
        item["type"] = type;
        item["unite_mesure"] = uniteMesure;
        item["date_formatee"] = dateFormatee;

        result.append(item);
    } else {
        qDebug() << "Aucune donnée trouvée pour ce capteur:" << query.lastError().text();
        // Ajouter un élément indiquant l'échec
        QVariantMap errorItem;
        errorItem["success"] = false;
        result.append(errorItem);
    }

    return result;
}


