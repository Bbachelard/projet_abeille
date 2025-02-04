#ifndef DATAIMPORTER_H
#define DATAIMPORTER_H
#include "QString"

class DataImporter
{
public:
    DataImporter();
    void exportToSD(QVector<float>data);
    void exportToLoRaWAN(QVector<float>data);
};

#endif // DATAIMPORTER_H


