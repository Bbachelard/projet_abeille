#ifndef ACQUISITION_H
#define ACQUISITION_H
#include "QString"

class Acquisition
{
private:
    float temperature,humidity,mass;
    float *data;
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

};

#endif // ACQUISITION_H
