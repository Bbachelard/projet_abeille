#ifndef ALERTEDATAMANAGER_H
#define ALERTEDATAMANAGER_H

#include "dataManager.h"

class AlerteDataManager : public dataManager
{
    Q_OBJECT
public:
    explicit AlerteDataManager(QObject *parent = nullptr);

    // Alertes
    Q_INVOKABLE void getAllAlertes();
    Q_INVOKABLE QVariantList getAlertesForCapteur(int id_capteur, float valeur_actuelle);
    Q_INVOKABLE bool addAlerte(int id_capteur, const QString &nom, const QString &phrase,
                               float valeur, int statut, int type, bool sens);
    Q_INVOKABLE bool deleteAlerte(int id_alerte);
    Q_INVOKABLE bool updateAlerte(int id_alerte, int id_capteur, const QString &nom, const QString &phrase,
                                  float valeur, int statut, int type, bool sens);

signals:
    void alertesReceived(int id, int id_capteur, QString nom, QString phrase, float valeur, bool statut, int type, bool sens);
};

#endif // ALERTEDATAMANAGER_H
