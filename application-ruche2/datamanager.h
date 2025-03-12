#ifndef DATAMANAGER_H
#define DATAMANAGER_H
#include <QObject>
#include "data.h"
#include <QDateTime>
#include<QString>
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
public:
    explicit dataManager(QObject *parent = nullptr);
    void connectDB();
    Q_INVOKABLE void saveData(int id_capteur, float valeur, QDateTime date_mesure);
    Q_INVOKABLE QVariantList getRucheData(int rucheId);

    void exportToSD(const Data &dataa);

    // save_admin,  save_user,    delete_admin,   delete_user,    get_admin,    get_user,
        Q_INVOKABLE void save_admin(QString id_compte,QString identifiant,QString password, int grade);
        Q_INVOKABLE bool authentification(QString a, QString b);
        Q_INVOKABLE bool is_superadmin(QString a);
        //Q_INVOKABLE void delete_admin();
        //Q_INVOKABLE void get_admin();
    //void save_user();void delete_user();void get_user();

};


#endif // DATAMANAGER_H
