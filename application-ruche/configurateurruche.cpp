#include "configurateurruche.h"

configurateurRuche::configurateurRuche(QObject *parent)
    : QObject(parent)
{
    // Aucune ruche n'est créée par défaut
}

configurateurRuche::~configurateurRuche()
{
    // Nettoyer la liste des ruches
    qDeleteAll(m_ruches);
    m_ruches.clear();
}

QVariantList configurateurRuche::getRuchesQML()
{
    QVariantList list;
    for (auto ruche : m_ruches) {
        list.append(QVariant::fromValue(ruche));
    }
    return list;
}

void configurateurRuche::addRuche(Ruche* ruche)
{
    if (!ruche) return;

    // Vérifier si la ruche existe déjà (par ID)
    for (auto existingRuche : m_ruches) {
        if (existingRuche->getId() == ruche->getId()) {
            qDebug() << "Ruche avec ID " << ruche->getId() << " existe déjà, mise à jour...";
            // Si une mise à jour spécifique est nécessaire, faites-la ici
            return;
        }
    }

    m_ruches.append(ruche);
    emit ruchesChanged();
    qDebug() << "Ruche ajoutée, total : " << m_ruches.size();
}

void configurateurRuche::removeRuche(int rucheId)
{
    for (int i = 0; i < m_ruches.size(); i++) {
        if (m_ruches.at(i)->getId() == rucheId) {
            Ruche* ruche = m_ruches.takeAt(i);
            delete ruche;
            emit ruchesChanged();
            return;
        }
    }
}

Ruche* configurateurRuche::getRucheById(int id)
{
    for (auto ruche : m_ruches) {
        if (ruche->getId() == id) {
            return ruche;
        }
    }
    return nullptr;
}

Ruche* configurateurRuche::createRuche(const QString& mqttAdresse)
{
    Ruche* newRuche = new Ruche(this);
    newRuche->setMqttAdresse(mqttAdresse);
    // L'ID sera défini lors de l'ajout à la base de données

    // Nous n'ajoutons pas la ruche directement au configurateur
    // car elle sera ajoutée après avoir été enregistrée en BDD

    qDebug() << "Nouvelle ruche créée avec adresse MQTT: " << mqttAdresse;
    return newRuche;
}
