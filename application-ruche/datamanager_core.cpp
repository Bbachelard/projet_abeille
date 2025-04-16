#include "dataManager.h"
#include <QProcess>
#include <QDebug>
#include <QFile>

dataManager::dataManager(QObject *parent) : QObject(parent) {
    connectDB();
}

void dataManager::connectDB()
{
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        db = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName("nom_base.sqlite");
    }

    // Ouvrir la connexion si elle n'est pas déjà ouverte
    if (!db.isOpen()) {
        if (!db.open()) {
            qDebug() << "Erreur lors de l'ouverture de la base de données:" << db.lastError().text();
        }
    }
}

QString dataManager::executeShellCommand(const QString &command)
{
    qDebug() << "Exécution de la commande:" << command;

    // Séparer la commande en programme et arguments
    QStringList commandParts = command.split(' ');
    QString program = commandParts.takeFirst();

    // Vérifier si le fichier existe
    QFile file(program);
    if (!file.exists()) {
        qDebug() << "ERREUR: Le fichier n'existe pas:" << program;
        return "Erreur: Fichier non trouvé";
    }

    // Exécuter la commande
    QProcess process;
    process.start(program, commandParts);

    // Attendre que le processus se termine
    if (!process.waitForFinished(60000)) { // Timeout de 60 secondes
        qDebug() << "Erreur: La commande a expiré";
        return "Erreur: La commande a expiré";
    }

    // Récupérer la sortie
    QString output = QString::fromUtf8(process.readAllStandardOutput());
    QString error = QString::fromUtf8(process.readAllStandardError());

    // Retourner le résultat
    if (process.exitCode() == 0) {
        return "Succès: " + output;
    } else {
        return "Erreur (" + QString::number(process.exitCode()) + "): " + error;
    }
}
