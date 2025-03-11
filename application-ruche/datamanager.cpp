#include "datamanager.h"


dataManager::dataManager(QObject *parent) : QObject(parent) {
    connectDB();
}

void dataManager::connectDB()
{
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        db = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");  // Utilisation du driver ODBC
        db.setDatabaseName("nom_base.sqlite");
    }
    if (!db.open()) {
        qDebug() << "Impossible de se connecter à la base de données !" << db.lastError().text();
    } else {
        qDebug() << "Connexion réussie à la base de données.";
    }
}
void dataManager::saveData(int id_capteur, float valeur, QDateTime date_mesure)
{

    if (!db.isOpen()) {
        qDebug() << "La base de données n'est pas connectée, tentative de reconnexion...";
        connectDB();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO donnees (id_capteur, valeur, date_mesure) VALUES (:id_capteur, :valeur, :date_mesure)");
    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":valeur", valeur);
    query.bindValue(":date_mesure", date_mesure.toString("yyyy-MM-dd HH:mm:ss"));

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'insertion des données :" << query.lastError().text();
    } else {
        qDebug() << "Donnée insérée avec succès !";
    }
}

QVariantList dataManager::getRucheData(int rucheId)
{
    QVariantList capteursList;

    if (!db.isOpen()) {
        qDebug() << "⚠️ La base de données n'est pas connectée, tentative de reconnexion...";
        connectDB();
    }

    QString queryString = R"(
        SELECT c.id_capteur, c.type, c.localisation, c.description, d.valeur, d.date_mesure
        FROM capteurs c
        LEFT JOIN donnees d ON c.id_capteur = d.id_capteur
        WHERE d.date_mesure = (
            SELECT MAX(d2.date_mesure) FROM donnees d2 WHERE d2.id_capteur = c.id_capteur
        )
        ORDER BY c.id_capteur;
    )";

    QSqlQuery query;

    if (!query.exec(queryString)) {
        qDebug() << "❌ Erreur lors de la récupération des capteurs :" << query.lastError().text();
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
    qDebug() << "fait";

    return capteursList;
}
