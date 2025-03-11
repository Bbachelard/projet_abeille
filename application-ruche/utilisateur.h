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

};

#endif // UTILISATEUR_H
