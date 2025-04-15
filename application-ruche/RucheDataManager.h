#ifndef RUCHEDATAMANAGER_H
#define RUCHEDATAMANAGER_H

#include "dataManager.h"

class RucheDataManager : public dataManager
{
    Q_OBJECT
public:
    explicit RucheDataManager(QObject *parent = nullptr);

    // Ruches
    Q_INVOKABLE int addOrUpdateRuche(const QString &name, const QString &adress, double batterie = 100.0);
    Q_INVOKABLE bool updateRucheBatterie(int rucheId, double batterie);
    Q_INVOKABLE QVariantList getRuchesList();
    Q_INVOKABLE QVariantList getRucheData(int id_ruche);
    Q_INVOKABLE QVariantList getRucheImages(int rucheId);
    Q_INVOKABLE bool addImage(int idImage, int idRuche, const QString& cheminFichier, const QString& dateCapture);
    Q_INVOKABLE bool deleteImage(int imageId, const QString& cheminFichier);

public slots:
    Q_INVOKABLE bool deleteRuche(int rucheId);

signals:
    void batteryUpdated(int rucheId, double batteryValue);
};

#endif // RUCHEDATAMANAGER_H
