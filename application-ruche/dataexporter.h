#ifndef DATAEXPORTER_H
#define DATAEXPORTER_H
#include "QString"

class dataExporter
{
private:
    QString connection;
public:
    dataExporter();
    void connectDB();
    void saveData(float *data);
    float* retrieveData();
};

#endif // DATAEXPORTER_H
