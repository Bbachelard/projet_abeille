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
    // Pas besoin d'exposer setId et setName à QML, car on les appelle ici
    // L'ID sera défini lors de l'ajout à la base de données
    qDebug() << "Nouvelle ruche créée avec adresse MQTT: " << mqttAdresse;

    // Ajouter directement la ruche au gestionnaire
    // addRuche(newRuche);  // Décommentez si vous voulez l'ajouter automatiquement

    return newRuche;
}


void configurateurRuche::updateRucheInfo(int id, const QString& name, const QString& mqttAdresse)
{
    Ruche* ruche = getRucheById(id);
    if (!ruche) {
        // Si la ruche n'existe pas encore, créez-la
        ruche = new Ruche(this);
        ruche->setId(id);
        ruche->setName(name);
        ruche->setMqttAdresse(mqttAdresse);
        addRuche(ruche);
    } else {
        // Mettre à jour une ruche existante
        ruche->setName(name);
        ruche->setMqttAdresse(mqttAdresse);
    }
}
