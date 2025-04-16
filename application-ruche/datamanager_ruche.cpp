#include "RucheDataManager.h"
#include <QFileInfo>

RucheDataManager::RucheDataManager(QObject *parent) : dataManager(parent)
{

}

QVariantList RucheDataManager::getRucheData(int id_ruche)
{
    QVariantList capteursList;
    if (!db.isOpen()) {
        connectDB();
    }
    QString queryString = R"(
        SELECT c.id_capteur, c.type, c.localisation, c.description, c.mesure, d.valeur, d.date_mesure, r.seuil_miel
        FROM capteurs c
        LEFT JOIN donnees d ON c.id_capteur = d.id_capteur
        LEFT JOIN ruche r ON d.id_ruche = r.id_ruche
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
        capteur["mesure"] = query.value("mesure").toString();
        capteur["valeur"] = query.value("valeur").toFloat();
        capteur["date_mesure"] = query.value("date_mesure").toString();
        capteur["seuil_miel"] = query.value("seuil_miel").toFloat();
        capteursList.append(capteur);
    }

    return capteursList;
}

int RucheDataManager::addOrUpdateRuche(const QString &name, const QString &adress, double batterie)
{
    if (!db.isOpen()) {
        connectDB();
    }
    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT id_ruche FROM ruche WHERE adress = :adress");
    checkQuery.bindValue(":adress", adress);

    if (checkQuery.exec() && checkQuery.next()) {
        int id_ruche = checkQuery.value(0).toInt();
        QSqlQuery updateQuery;
        updateQuery.prepare("UPDATE ruche SET name = :name, batterie = :batterie WHERE id_ruche = :id_ruche");
        updateQuery.bindValue(":name", name);
        updateQuery.bindValue(":batterie", batterie);
        updateQuery.bindValue(":id_ruche", id_ruche);

        if (!updateQuery.exec()) {
            qDebug() << "Erreur lors de la mise à jour de la ruche:" << updateQuery.lastError().text();
        }
        return id_ruche;
    } else {
        QSqlQuery insertQuery;
        insertQuery.prepare("INSERT INTO ruche (name, adress, batterie) VALUES (:name, :adress, :batterie)");
        insertQuery.bindValue(":name", name);
        insertQuery.bindValue(":adress", adress);
        insertQuery.bindValue(":batterie", batterie);

        if (!insertQuery.exec()) {
            qDebug() << "Erreur lors de l'ajout de la ruche:" << insertQuery.lastError().text();
            return -1;
        }

        return insertQuery.lastInsertId().toInt();
    }
}

bool RucheDataManager::updateRucheBatterie(int rucheId, double batterie)
{
    if (!db.isOpen()) {
        connectDB();
    }
    QSqlQuery query;
    query.prepare("UPDATE ruche SET batterie = :batterie WHERE id_ruche = :id_ruche");
    query.bindValue(":batterie", batterie);
    query.bindValue(":id_ruche", rucheId);
    if (!query.exec()) {
        qDebug() << "Erreur lors de la mise à jour de la batterie:" << query.lastError().text();
        return false;
    }
    emit batteryUpdated(rucheId, batterie);
    return true;
}

QVariantList RucheDataManager::getRuchesList()
{
    QVariantList ruchesList;

    if (!db.isOpen()) {
        connectDB();
    }
    QSqlQuery query;
    if (!query.exec("SELECT id_ruche, name, adress, batterie FROM ruche ORDER BY id_ruche")) {
        qDebug() << "Erreur lors de la récupération de la liste des ruches:" << query.lastError().text();
        return ruchesList;
    }
    while (query.next()) {
        QVariantMap ruche;
        ruche["id_ruche"] = query.value("id_ruche").toInt();
        ruche["name"] = query.value("name").toString();
        ruche["adress"] = query.value("adress").toString();
        ruche["batterie"] = query.value("batterie").toDouble();

        ruchesList.append(ruche);
    }
    return ruchesList;
}

bool RucheDataManager::deleteRuche(int rucheId)
{
    if (!db.isOpen()) {
        connectDB();
    }
    if (!db.transaction()) {
        qDebug() << "Erreur lors du démarrage de la transaction:" << db.lastError().text();
        return false;
    }

    QSqlQuery deleteDataQuery;
    deleteDataQuery.prepare("DELETE FROM donnees WHERE id_ruche = :id_ruche");
    deleteDataQuery.bindValue(":id_ruche", rucheId);

    if (!deleteDataQuery.exec()) {
        qDebug() << "Erreur lors de la suppression des données:" << deleteDataQuery.lastError().text();
        db.rollback();
        return false;
    }

    QSqlQuery deleteRucheQuery;
    deleteRucheQuery.prepare("DELETE FROM ruche WHERE id_ruche = :id_ruche");
    deleteRucheQuery.bindValue(":id_ruche", rucheId);
    if (!deleteRucheQuery.exec()) {
        qDebug() << "Erreur lors de la suppression de la ruche:" << deleteRucheQuery.lastError().text();
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

QVariantList RucheDataManager::getRucheImages(int rucheId)
{
    QVariantList results;

    if (rucheId <= 0) {
        qDebug() << "ID de ruche invalide pour récupérer des images:" << rucheId;
        return results;
    }

    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("SELECT id_image, chemin_fichier, date_capture FROM images WHERE id_ruche = ? ORDER BY date_capture DESC");
    query.addBindValue(rucheId);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap image;
            image["id_image"] = query.value("id_image").toInt();
            image["chemin_fichier"] = query.value("chemin_fichier").toString();
            image["date_capture"] = query.value("date_capture").toString();

            results.append(image);
        }

        qDebug() << "Images récupérées pour la ruche" << rucheId << ":" << results.size();
    } else {
        qDebug() << "Erreur lors de la récupération des images:" << query.lastError().text();
    }

    return results;
}

bool RucheDataManager::addImage(int idImage, int idRuche, const QString& cheminFichier, const QString& dateCapture)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT id_image FROM images WHERE id_image = ? AND id_ruche = ?");
    checkQuery.addBindValue(idImage);
    checkQuery.addBindValue(idRuche);

    if (checkQuery.exec() && checkQuery.next()) {
        // L'image existe déjà
        qDebug() << "Image existe déjà:" << idImage << "pour ruche" << idRuche;
        return false;
    }

    // Ajouter la nouvelle image
    QSqlQuery query;
    query.prepare("INSERT INTO images (id_image, id_ruche, chemin_fichier, date_capture) "
                  "VALUES (?, ?, ?, ?)");
    query.addBindValue(idImage);
    query.addBindValue(idRuche);
    query.addBindValue(cheminFichier);
    query.addBindValue(dateCapture);

    bool success = query.exec();

    if (!success) {
        qDebug() << "Erreur lors de l'ajout de l'image:" << query.lastError().text();
    } else {
        qDebug() << "Image ajoutée avec succès:" << idImage << "pour ruche" << idRuche;
    }

    return success;
}


bool RucheDataManager::deleteImage(int imageId, const QString& cheminFichier)
{
    if (!db.isOpen()) {
        connectDB();
    }
    if (!db.transaction()) {
        qDebug() << "Erreur lors du démarrage de la transaction:" << db.lastError().text();
        return false;
    }
    QSqlQuery query;
    query.prepare("DELETE FROM images WHERE id_image = ?");
    query.addBindValue(imageId);
    if (!query.exec()) {
        qDebug() << "Erreur lors de la suppression de l'image dans la BDD:" << query.lastError().text();
        db.rollback();
        return false;
    }
    QString cheminAbsolu = QFileInfo("deleteimage.sh").absoluteFilePath();
    qDebug() << "Chemin absolu du script:" << cheminAbsolu;
    QString scriptCmd = QString("/bin/sh %1 %2 skip_db").arg(cheminAbsolu).arg(cheminFichier);
    qDebug() << "Exécution de la commande:" << scriptCmd;
    int scriptResult = system(scriptCmd.toUtf8().constData());
    bool fileDeleted = (scriptResult == 0);
    // Valider la transaction
    if (!db.commit()) {
        qDebug() << "Erreur lors de la validation de la transaction:" << db.lastError().text();
        db.rollback();
        return false;
    }
    // Journalisation du résultat
    if (fileDeleted) {
        qDebug() << "Image supprimée avec succès. ID:" << imageId
                 << "Fichier:" << cheminFichier;
    } else {
        qDebug() << "Image supprimée de la BDD, mais erreur lors de l'exécution du script. ID:" << imageId
                 << "Fichier:" << cheminFichier
                 << "Code retour:" << scriptResult;
    }
    return true;
}
