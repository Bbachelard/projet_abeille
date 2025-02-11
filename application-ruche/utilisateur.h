#ifndef UTILISATEUR_H
#define UTILISATEUR_H

#include "QString"
#include <QObject>

class Utilisateur : public QObject
{
    Q_OBJECT
private:
    int id_ruche;

public:
    explicit Utilisateur(QObject *parent = nullptr);
    virtual ~Utilisateur();
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
