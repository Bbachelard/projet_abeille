#ifndef ACQUISITION_H
#define ACQUISITION_H
#include "QString"
#include <QVector>
#include <QImage>

struct data{
    float temperature,humidity,mass;
    QString imgPath;
};

class Acquisition
{
private:
    QVector<data> dataList;
    /*
    QSerialBus i2cInterface;
    QIODevice spiInterface;
    QImage csiInterface;
    array Matrix;
    Image standardImage;*/
public:
    Acquisition();
    void startSensors();
    void captureImage();
    QVector<data> getData() const;

};

#endif // ACQUISITION_H
