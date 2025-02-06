#ifndef ADMINISTRATEUR_H
#define ADMINISTRATEUR_H

#include "utilisateur.h"
#include "QString"

class Administrateur: public Utilisateur
{
public:
    Administrateur();
    void creerCompte(QString a, QString b);
    bool authentification(QString a, QString b);
    /*void displayData();
    void startAcquisition();
    void exportData();*/

private:
    QString pw;
    QString id;

};

#endif // ADMINISTRATEUR_H
