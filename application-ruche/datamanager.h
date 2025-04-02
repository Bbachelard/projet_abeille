#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QObject>
#include "data.h"
#include <QDateTime>
#include <QString>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantList>

class dataManager : public QObject
{
    Q_OBJECT
private:
    QString connection;
    QSqlDatabase db;
    int rucheActiveId = -1;

public:
    explicit dataManager(QObject *parent = nullptr);
    void connectDB();

    // Données
    Q_INVOKABLE void saveData(int id_ruche, int id_capteur, float valeur, QDateTime date_mesure);
    Q_INVOKABLE QVariantList getRucheData(int id_ruche);
    Q_INVOKABLE QVariantList getCapteurGraphData(int id_ruche, int id_capteur);
    Q_INVOKABLE QVariantList getAllRucheData();

    // Ruches
    Q_INVOKABLE int addOrUpdateRuche(const QString &name, const QString &adress, double batterie = 100.0);
    Q_INVOKABLE bool updateRucheBatterie(int rucheId, double batterie);
    Q_INVOKABLE QVariantList getRuchesList();
    Q_INVOKABLE QVariantList getRucheImages(int rucheId);
    Q_INVOKABLE bool addImage(int idImage, int idRuche, const QString& cheminFichier, const QString& dateCapture);
    Q_INVOKABLE bool deleteImage(int imageId, const QString& cheminFichier);

    // Utilitaires système
    Q_INVOKABLE QString executeShellCommand(const QString &command);

    // Authentification
    Q_INVOKABLE bool authentification(QString a, QString b);
    Q_INVOKABLE bool is_superadmin(QString a);
    Q_INVOKABLE void adduser(QString id, QString pw, int grade);
    Q_INVOKABLE bool verifUser(const QString& user);
    Q_INVOKABLE void modifpw(QString id, QString pw);
    Q_INVOKABLE void modifgrade(QString id, int grade);

public slots:
    Q_INVOKABLE bool deleteRuche(int rucheId);
    Q_INVOKABLE int addCapteur(int rucheId, const QString &type, const QString &localisation, const QString &description);
    Q_INVOKABLE bool deleteCapteur(int capteurId);

signals:
    void rucheActiveChanged();
};

#endif // DATAMANAGER_H
