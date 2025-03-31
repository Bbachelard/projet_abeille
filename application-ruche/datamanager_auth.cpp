#include "datamanager.h"

bool dataManager::authentification(QString a, QString b)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("SELECT password, grade FROM compte WHERE identifiant = :id");
    query.bindValue(":id", a);
    if (!query.exec())
    {
        qWarning() << "Erreur SQL:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        QString storedPassword = query.value(0).toString();
        int grade = query.value(1).toInt();

        if (b == storedPassword) {
            if (grade > 1) {
                qDebug() << "✅ Authentification réussie pour ID:" << a;
                return true;
            } else {
                qWarning() << "⛔ Accès refusé: Grade insuffisant" << a;
            }
        } else {
            qWarning() << "⛔ Mot de passe ou identifiant incorrect" << a;
        }
    } else {
        qWarning() << "⛔ Aucun compte trouvé" << a;
    }
    return false;
}

bool dataManager::is_superadmin(QString a)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery grade;
    grade.prepare("SELECT grade FROM compte WHERE identifiant = :valeur");
    grade.bindValue(":valeur", a);

    if (!grade.exec())
    {
        qWarning() << "Erreur SQL:" << grade.lastError().text();
        return false;
    }

    if (grade.next())
    {
        int count = grade.value(0).toInt();
        if(count==3)
        {
            return true;
        }
    }
    return false;
}

void dataManager::adduser(QString id, QString pw, int grade)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO compte (identifiant, password, grade) VALUES (:id, :password, :grade)");
    query.bindValue(":id", id);
    query.bindValue(":password", pw);
    query.bindValue(":grade", grade);

    if (!query.exec()) {
        qDebug() << "Erreur lors de l'ajout de l'utilisateur:" << query.lastError().text();
    }
}

void dataManager::modifpw(QString id, QString pw)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("UPDATE compte SET password = :password WHERE identifiant = :id");
    query.bindValue(":id", id);
    query.bindValue(":password", pw);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la modification du mot de passe:" << query.lastError().text();
    }
}

void dataManager::modifgrade(QString id, int grade)
{
    if (!db.isOpen()) {
        connectDB();
    }

    QSqlQuery query;
    query.prepare("UPDATE compte SET grade = :grade WHERE identifiant = :id");
    query.bindValue(":id", id);
    query.bindValue(":grade", grade);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la modification du grade:" << query.lastError().text();
    }
}
