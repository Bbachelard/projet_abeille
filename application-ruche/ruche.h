#ifndef RUCHE_H
#define RUCHE_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QVector>
#include <QVariant>
#include <QDebug>
#include "data.h"

class Ruche : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ getId NOTIFY idChanged)
    Q_PROPERTY(QVariantList dataList READ getDataList NOTIFY dataListChanged)
    Q_PROPERTY(QString mqttAdresse READ getMqttAdresse WRITE setMqttAdresse NOTIFY mqttAdresseChanged)


private:
    int id;
    QString mqttAdresse;
    QVector<Data> dataList;
    static int nextId;

public:
    explicit Ruche(QObject *parent = nullptr, const QString &mqttAdresse = "");
    Q_INVOKABLE void setData(float m_temp,float m_hum,float m_mass, float m_pression,QString m_imgPath,QDateTime m_dateTime);
    Q_INVOKABLE QVariantList getDataList() const;
    Q_INVOKABLE int getId()const;


    QString getMqttAdresse() const;
    void setMqttAdresse(const QString &adresse);
    static Ruche *createTestRuche();

signals:
    void idChanged();
    void dataListChanged();
    void mqttAdresseChanged();
};
#endif // RUCHE_H
