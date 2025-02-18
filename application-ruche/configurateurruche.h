#ifndef CONFIGURATEURRUCHE_H
#define CONFIGURATEURRUCHE_H

#include <QObject>
#include <QList>
#include <QQmlListProperty>
#include "ruche.h"

class configurateurRuche : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Ruche> ruches READ getRuchesQml NOTIFY ruchesChanged)

public:
    explicit configurateurRuche(QObject *parent = nullptr);
    QQmlListProperty<Ruche> getRuchesQml();

    Q_INVOKABLE void addRuche(Ruche* ruche);
    QList<Ruche*> getRuchesList() const;

private:
    QList<Ruche*> ruchesList;
    static void appendRuche(QQmlListProperty<Ruche> *list, Ruche *ruche);
    static int countRuche(QQmlListProperty<Ruche> *list);
    static Ruche* atRuche(QQmlListProperty<Ruche> *list, int index);
    static void clearRuche(QQmlListProperty<Ruche> *list);

signals:
    void ruchesChanged();
};

#endif // CONFIGURATEURRUCHE_H
