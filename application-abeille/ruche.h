#ifndef RUCHE_H
#define RUCHE_H

#include "QString"
#include <QDate>

struct data{
    float temperature,humidity,mass,pression;
    QString imgPath;
    QDateTime dateTime;
};

class Ruche
{
private:
    int id;
    QVector<data> dataList;
    static int nextId;

public:
    Ruche();
    void setData(float m_temp,float m_hum,float m_mass, float m_pression,QString m_imgPath,QDateTime m_dateTime);
    data getData()const;
};

#endif // RUCHE_H
