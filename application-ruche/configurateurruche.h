#ifndef CONFIGURATEURRUCHE_H
#define CONFIGURATEURRUCHE_H

#include <QObject>
#include <QList>
#include <QQmlListProperty>
#include "ruche.h"

class configurateurRuche : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList ruches READ getRuchesQML NOTIFY ruchesChanged)

public:
    explicit configurateurRuche(QObject *parent = nullptr);
    ~configurateurRuche();

    QVariantList getRuchesQML();
    QList<Ruche*> getRuchesList() const { return m_ruches; }

    void addRuche(Ruche* ruche);
    void removeRuche(int rucheId);
    Ruche* getRucheById(int id);

    Q_INVOKABLE Ruche* createRuche(const QString& mqttAdresse);

signals:
    void ruchesChanged();

private:
    QList<Ruche*> m_ruches;
};

#endif // CONFIGURATEURRUCHE_H
