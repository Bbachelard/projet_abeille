#ifndef DATAIMPORTER_H
#define DATAIMPORTER_H
#include "QString"

class Dataimporter
{
public:
    Dataimporter();
    void exportToSD(QVector<float>data);
    void exportToLoRaWAN(QVector<float>data);
};

#endif // DATAIMPORTER_H


