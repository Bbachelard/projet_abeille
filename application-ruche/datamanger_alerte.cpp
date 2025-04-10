#include "datamanager.h"



QVariantList dataManager::getAlertesForCapteur(int id_capteur, float valeur_actuelle)
{
    QVariantList result;
    if (!db.isOpen()) {
        connectDB();
    }

    // Récupérer les alertes actives pour ce capteur spécifique
    QSqlQuery query;
    // Nous trions déjà par type dans la requête pour obtenir d'abord les types plus élevés
    query.prepare("SELECT id, nom, phrase, valeur, statut, type, sens FROM alertes "
                  "WHERE id_capteur = :id_capteur AND statut = 1 "
                  "ORDER BY type DESC");
    query.bindValue(":id_capteur", id_capteur);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la récupération des alertes:" << query.lastError().text();
        return result;
    }

    // Liste pour stocker les alertes déclenchées pour ce capteur
    QList<QVariantMap> alertesDeclenchees;

    while (query.next()) {
        int id = query.value("id").toInt();
        QString nom = query.value("nom").toString();
        QString phrase = query.value("phrase").toString();
        float valeur_seuil = query.value("valeur").toFloat();
        bool statut = query.value("statut").toBool();
        int type = query.value("type").toInt();
        bool sens = query.value("sens").toBool();

        // Vérifier si la condition d'alerte est remplie
        bool alerte_declenchee = false;

        if (statut == 1) {
            if (sens == 0 ) {
                if (valeur_actuelle >= valeur_seuil) {
                    alerte_declenchee = true;
                }
            }
            else {
                if (valeur_actuelle <= valeur_seuil) {
                    alerte_declenchee = true;
                }
            }
        }

        // Si l'alerte est déclenchée, l'ajouter à la liste
        if (alerte_declenchee) {
            QVariantMap alerteItem;
            alerteItem["id"] = id;
            alerteItem["nom"] = nom;
            alerteItem["phrase"] = phrase;
            alerteItem["valeur_seuil"] = valeur_seuil;
            alerteItem["valeur_actuelle"] = valeur_actuelle;
            alerteItem["declenchee"] = true;
            alerteItem["type"] = type;
            alertesDeclenchees.append(alerteItem);
        }
    }

    // Conversion de la liste en QVariantList pour le résultat final
    // Comme les alertes sont déjà triées par type (décroissant) dans la requête SQL,
    // elles seront naturellement dans l'ordre de priorité souhaité
    for (const QVariantMap &alerte : alertesDeclenchees) {
        result.append(alerte);
    }

    return result;
}

void dataManager::getAllAlertes()
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("SELECT id, id_capteur, nom, phrase, valeur, statut, type , sens FROM alertes ORDER BY id_capteur, type DESC");

    if (!query.exec()) {
        qDebug() << "Erreur lors de la récupération des alertes:" << query.lastError().text();
        return;
    }

    while (query.next()) {
        int id = query.value("id").toInt();
        int id_capteur = query.value("id_capteur").toInt();
        QString nom = query.value("nom").toString();
        QString phrase = query.value("phrase").toString();
        float valeur = query.value("valeur").toFloat();
        bool statut = query.value("statut").toBool();
        int type = query.value("type").toInt();
        bool sens = query.value("sens").toBool();

        // Émettre le signal pour chaque alerte
        emit alertesReceived(id, id_capteur, nom, phrase, valeur, statut, type,sens);
    }
}

// Fonction pour ajouter une alerte
bool dataManager::addAlerte(int id_capteur, const QString &nom, const QString &phrase,
                            float valeur, int statut, int type, bool sens)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO alertes (id_capteur, nom, phrase, valeur, statut, type, sens) "
                  "VALUES (:id_capteur, :nom, :phrase, :valeur, :statut, :type)");

    query.bindValue(":id_capteur", id_capteur);
    query.bindValue(":nom", nom);
    query.bindValue(":phrase", phrase);
    query.bindValue(":valeur", valeur);
    query.bindValue(":statut", statut);
    query.bindValue(":type", type);
    query.bindValue(":sens", sens);

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'ajout d'une alerte:" << query.lastError().text();
        return false;
    }

    return true;
}

// Fonction pour supprimer une alerte
bool dataManager::deleteAlerte(int id_alerte)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("DELETE FROM alertes WHERE id = :id");
    query.bindValue(":id", id_alerte);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la suppression d'une alerte:" << query.lastError().text();
        return false;
    }

    return true;
}

bool dataManager::updateAlerte(int id_alerte, int id_capteur, const QString &nom, const QString &phrase,
                               float valeur, int statut, int type, bool sens)
{
    if (!db.isOpen()) {
        connectDB();
    }

    // Vérifier d'abord si cette combinaison id_capteur/phrase existe déjà pour un autre id
    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT id FROM alertes WHERE id_capteur = :id_capteur AND phrase = :phrase AND id != :id");
    checkQuery.bindValue(":id_capteur", id_capteur);
    checkQuery.bindValue(":phrase", phrase);
    checkQuery.bindValue(":id", id_alerte);

    if (!checkQuery.exec()) {
        qDebug() << "Erreur lors de la vérification de l'unicité:" << checkQuery.lastError().text();
        return false;
    }

    // Si une correspondance est trouvée, cela violerait la contrainte d'unicité
    if (checkQuery.next()) {
        qDebug() << "Modification impossible: cette combinaison capteur/phrase existe déjà";
        return false;
    }

    // Si tout est OK, procéder à la mise à jour
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE alertes SET "
                        "id_capteur = :id_capteur, "
                        "nom = :nom, "
                        "phrase = :phrase, "
                        "valeur = :valeur, "
                        "statut = :statut, "
                        "type = :type, "
                        "sens =:sens "
                        "WHERE id = :id");

    updateQuery.bindValue(":id", id_alerte);
    updateQuery.bindValue(":id_capteur", id_capteur);
    updateQuery.bindValue(":nom", nom);
    updateQuery.bindValue(":phrase", phrase);
    updateQuery.bindValue(":valeur", valeur);
    updateQuery.bindValue(":statut", statut);
    updateQuery.bindValue(":type", type);
    updateQuery.bindValue(":sens", sens);

    if (!updateQuery.exec()) {
        qDebug() << "Erreur lors de la mise à jour d'une alerte:" << updateQuery.lastError().text();
        return false;
    }

    return true;
}
