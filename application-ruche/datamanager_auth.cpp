#include "UserDataManager.h"
#include "qtbcrypt.h"

UserDataManager::UserDataManager(QObject *parent) : dataManager(parent)
{
    // Initialisation spécifique pour UserDataManager
}

bool UserDataManager::authentification(QString a, QString b)
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
        QString storedHashedPassword = query.value(0).toString();
        int grade = query.value(1).toInt();

        // Utilisation de BCrypt pour vérifier le mot de passe
        // Le sel est inclus dans le hash stocké, donc pas besoin de le récupérer séparément
        QString hashedInputPassword = QtBCrypt::hashPassword(b, storedHashedPassword);

        if (hashedInputPassword == storedHashedPassword) {
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

bool UserDataManager::is_superadmin(QString a)
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

void UserDataManager::adduser(QString id, QString pw, int grade)
{
    if (!db.isOpen()) {
        connectDB();
    }

    // Génération du sel et hachage du mot de passe avec BCrypt
    QString salt = QtBCrypt::generateSalt();
    QString hashedPassword = QtBCrypt::hashPassword(pw, salt);

    QSqlQuery query;
    query.prepare("INSERT INTO compte (identifiant, password, grade) VALUES (:id, :password, :grade)");
    query.bindValue(":id", id);
    query.bindValue(":password", hashedPassword);  // Utilisation du mot de passe haché
    query.bindValue(":grade", grade);
    if (!query.exec()) {
        qDebug() << "Erreur lors de l'ajout de l'utilisateur:" << query.lastError().text();
    }
}

bool UserDataManager::verifUser(const QString& user)
{
    if (!db.isOpen()) {
        connectDB();
    }
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM compte WHERE identifiant = :id");
    query.bindValue(":id", user);

    if (!query.exec()) {
        qDebug() << "Erreur lors de la vérification de l'utilisateur:" << query.lastError().text();
        return false;
    }
    // Si un résultat est trouvé, l'utilisateur existe
    if (query.next() && query.value(0).toInt() > 0) {
        return true;
    }
    return false;
}


void UserDataManager::modifpw(QString id, QString pw)
{
    if (!db.isOpen()) {
        connectDB();
    }

    // Génération du sel et hachage du mot de passe avec BCrypt
    QString salt = QtBCrypt::generateSalt();
    QString hashedPassword = QtBCrypt::hashPassword(pw, salt);

    QSqlQuery query;
    query.prepare("UPDATE compte SET password = :password WHERE identifiant = :id");
    query.bindValue(":id", id);
    query.bindValue(":password", hashedPassword);  // Utilisation du mot de passe haché
    if (!query.exec()) {
        qDebug() << "Erreur lors de la modification du mot de passe:" << query.lastError().text();
    }
}

void UserDataManager::modifgrade(QString id, int grade)
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
