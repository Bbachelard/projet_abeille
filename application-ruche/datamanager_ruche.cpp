#include "datamanager.h"
#include <QFile>

int dataManager::addOrUpdateRuche(const QString &name, const QString &adress, double batterie)
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

bool dataManager::updateRucheBatterie(int rucheId, double batterie)
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

    return true;
}

QVariantList dataManager::getRuchesList()
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

bool dataManager::deleteRuche(int rucheId)
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

QVariantList dataManager::getRucheImages(int rucheId)
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

bool dataManager::addImage(int idImage, int idRuche, const QString& cheminFichier, const QString& dateCapture)
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


bool dataManager::deleteImage(int imageId, const QString& cheminFichier)
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

    QString cheminComplet;
    cheminComplet = cheminFichier;

    QFile file(cheminComplet);
    bool fileDeleted = true;
    if (!file.exists()) {
        qDebug() << "Le fichier n'existe pas:" << cheminComplet;
    } else {
        QString cmd = QString("sudo rm -rf \"%1\"").arg(cheminComplet);
        system(cmd.toUtf8().constData());
    }
    if (!db.commit()) {
        qDebug() << "Erreur lors de la validation de la transaction:" << db.lastError().text();
        db.rollback();
        return false;
    }
    if (fileDeleted) {
        qDebug() << "Image supprimée avec succès. ID:" << imageId << "Chemin:" << cheminComplet;
    } else {
        qDebug() << "Image supprimée de la BDD, mais le fichier n'a pas pu être supprimé. ID:" << imageId << "Chemin:" << cheminComplet;
    }

    return true;
}
