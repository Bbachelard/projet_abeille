#ifndef DATA_H
#define DATA_H

#include <QString>
#include <QDateTime>
#include <QObject>
#include <QMetaType>

struct Data {
    Q_GADGET  // Permet à Qt de reconnaître cette struct comme un type utilisable en QML

    Q_PROPERTY(float temperature MEMBER temperature)
    Q_PROPERTY(float humidity MEMBER humidity)
    Q_PROPERTY(float mass MEMBER mass)
    Q_PROPERTY(float pression MEMBER pression)
    Q_PROPERTY(QString imgPath MEMBER imgPath)
    Q_PROPERTY(QString dateTime READ getDateTime WRITE setDateTime)

public:
    float temperature;
    float humidity;
    float mass;
    float pression;
    QString imgPath;
    QDateTime dateTime;

    QString getDateTime() const { return dateTime.toString(Qt::ISODate); }
    void setDateTime(const QString &dt) { dateTime = QDateTime::fromString(dt, Qt::ISODate); }
};

Q_DECLARE_METATYPE(Data)  // Permet d'utiliser `Data` avec QVariant

#endif // DATA_H
