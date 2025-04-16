#ifndef USERDATAMANAGER_H
#define USERDATAMANAGER_H

#include "dataManager.h"

class UserDataManager : public dataManager
{
    Q_OBJECT
public:
    explicit UserDataManager(QObject *parent = nullptr);

    // Authentification
    Q_INVOKABLE bool authentification(QString a, QString b);
    Q_INVOKABLE bool is_superadmin(QString a);
    Q_INVOKABLE void adduser(QString id, QString pw, int grade);
    Q_INVOKABLE bool verifUser(const QString& user);
    Q_INVOKABLE void modifpw(QString id, QString pw);
    Q_INVOKABLE void modifgrade(QString id, int grade);
};

#endif // USERDATAMANAGER_H
