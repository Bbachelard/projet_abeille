#ifndef SENSORDATAMANAGER_H
#define SENSORDATAMANAGER_H

#include "dataManager.h"

class SensorDataManager : public dataManager
{
    Q_OBJECT
public:
    explicit SensorDataManager(QObject *parent = nullptr);

    // Données
    Q_INVOKABLE void saveData(int id_ruche, int id_capteur, float valeur, QDateTime date_mesure);
    Q_INVOKABLE QVariantList getCapteurGraphData(int id_ruche, int id_capteur);
    Q_INVOKABLE QVariantList getAllRucheData();
    Q_INVOKABLE QVariantList getLastCapteurValue(int id_capteur, int id_ruche);
signals:
    void dataLoaded(QVariantList data);
    void chartDataLoaded(QVariantList data, QDateTime minDate, QDateTime maxDate, QString capteurType, bool isMultiple);
};

#endif // SENSORDATAMANAGER_H
