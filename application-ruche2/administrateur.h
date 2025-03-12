#ifndef ADMINISTRATEUR_H
#define ADMINISTRATEUR_H

#include "utilisateur.h"
#include "QString"
#include <QObject>

class Administrateur: public Utilisateur
{
     Q_OBJECT
public:
    Administrateur(QObject *parent = nullptr);
    void creerCompte(QString a, QString b);
    Q_INVOKABLE bool authentification(QString a, QString b);
    /*void displayData();
    void startAcquisition();
    void exportData();*/

private:
    QString pw;
    QString id;

};
#endif // ADMINISTRATEUR_H
