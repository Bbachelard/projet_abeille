#ifndef UTILISATEUR_H
#define UTILISATEUR_H

#include "QString"

class Utilisateur
{
private:
    int id_ruche;

public:
    Utilisateur();
    void choix_ruche();
    float get_humi();
    float get_temp();
    float get_press();
    float get_poid();
    void alerte_limite();
    void afficher();
    QString get_img();
};

#endif // UTILISATEUR_H
