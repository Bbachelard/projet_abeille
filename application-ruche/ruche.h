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

private:
    int id;
    QVector<Data> dataList;
    static int nextId;

public:
    explicit Ruche(QObject *parent = nullptr);
    Q_INVOKABLE void setData(float m_temp,float m_hum,float m_mass, float m_pression,QString m_imgPath,QDateTime m_dateTime);
    Q_INVOKABLE QVariantList getDataList() const;
    Q_INVOKABLE int getId()const;

    static Ruche *createTestRuche();

signals:
    void idChanged();
    void dataListChanged();
};
#endif // RUCHE_H
