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
    Q_INVOKABLE QVariantList getRucheData();
    Q_INVOKABLE QVariantList getCapteurGraphData(int id_capteur);
    Q_INVOKABLE QVariantList getAllRucheData();

    Q_INVOKABLE bool authentification(QString a, QString b);
    Q_INVOKABLE bool is_superadmin(QString a);

    void exportToSD(const Data &dataa);

};


#endif // DATAMANAGER_H
