#include "ruche.h"
int Ruche::nextId = 0;

Ruche::Ruche()
{
    id = nextId++;
}

void Ruche::setData(float m_temp, float m_hum, float m_mass, float m_pression, QString m_imgPath, QDateTime m_dateTime)
{
    data newData;
    newData.temperature=m_temp;
    newData.humidity=m_hum;
    newData.mass=m_mass;
    newData.pression=m_pression;
    newData.imgPath=m_imgPath;
    newData.dateTime=m_dateTime;
    dataList.append(newData);
}

data Ruche::getData()const
{
    return dataList.last();
}
