#ifndef DATAEXPORTER_H
#define DATAEXPORTER_H
#include <QObject>
#include "data.h"
#include <QDateTime>
#include<QString>

class dataExporter : public QObject
{
    Q_OBJECT
private:
    QString connection;
public:
    explicit dataExporter(QObject *parent = nullptr);
    void connectDB();
    Q_INVOKABLE void saveData(int id_capteur, float valeur, QDateTime date_mesure);
    void exportToSD(const Data &dataa);
    void exportToLoRaWAN(const Data &dataa);

};


#endif // DATAEXPORTER_H
