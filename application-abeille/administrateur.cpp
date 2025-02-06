#include "administrateur.h"

Administrateur::Administrateur()
{
    id = "root";
    pw = "root";
}

void Administrateur::creerCompte(QString a,QString b)
{
    id = a;
    pw = b;
}

bool Administrateur::authentification(QString a,QString b)
{
    if (a==id)
    {
        if (b==pw)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}


