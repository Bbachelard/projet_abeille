#include "configurateurruche.h"


configurateurRuche::configurateurRuche(QObject *parent) : QObject(parent)
{

}

QQmlListProperty<Ruche> configurateurRuche::getRuchesQml()
{
    return QQmlListProperty<Ruche>(this, &ruchesList, &appendRuche, &countRuche, &atRuche, &clearRuche);
}


QList<Ruche*> configurateurRuche::getRuchesList() const
{
    return ruchesList;
}


void configurateurRuche::addRuche(Ruche* ruche)
{
    if (ruche && !ruchesList.contains(ruche)) {
        ruchesList.append(ruche);
        emit ruchesChanged();
    }
}

void configurateurRuche::appendRuche(QQmlListProperty<Ruche> *list, Ruche *ruche)
{
    reinterpret_cast<QList<Ruche*>*>(list->data)->append(ruche);
}

int configurateurRuche::countRuche(QQmlListProperty<Ruche> *list)
{
    return reinterpret_cast<QList<Ruche*>*>(list->data)->size();
}

Ruche* configurateurRuche::atRuche(QQmlListProperty<Ruche> *list, int index)
{
    return reinterpret_cast<QList<Ruche*>*>(list->data)->at(index);
}

void configurateurRuche::clearRuche(QQmlListProperty<Ruche> *list)
{
    reinterpret_cast<QList<Ruche*>*>(list->data)->clear();
}
