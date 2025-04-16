#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantList>

class dataManager : public QObject
{
    Q_OBJECT
protected:
    QString connection;
    QSqlDatabase db;
    int rucheActiveId = -1;

public:
    explicit dataManager(QObject *parent = nullptr);
    virtual void connectDB();
    Q_INVOKABLE QString executeShellCommand(const QString &command);

signals:
    void rucheActiveChanged();
};

#endif // BASEDATAMANAGER_H
