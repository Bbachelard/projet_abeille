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

};


#endif // DATAMANAGER_H
