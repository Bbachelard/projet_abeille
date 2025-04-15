#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "dataManager.h"
#include "RucheDataManager.h"
#include "SensorDataManager.h"
#include "AlerteDataManager.h"
#include "UserDataManager.h"

#include "MqttHandler.h"
#include "configurateurruche.h"
#include "data.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    dataManager dManager;
    RucheDataManager rucheManager;
    SensorDataManager sensorManager;
    AlerteDataManager alerteManager;
    UserDataManager userManager;


    configurateurRuche configurateur;
    dManager.connectDB();
    MqttHandler mqttHandler(&configurateur, &rucheManager, &sensorManager);

    QVariantList ruchesList = rucheManager.getRuchesList();
    for (int i = 0; i < ruchesList.size(); ++i) {
        QVariantMap rucheData = ruchesList[i].toMap();

        Ruche* ruche = new Ruche();
        ruche->setId(rucheData["id_ruche"].toInt());
        ruche->setName(rucheData["name"].toString());
        ruche->setMqttAdresse(rucheData["adress"].toString());
        configurateur.addRuche(ruche);
    }

    qmlRegisterType<Ruche>("com.example.ruche", 1, 0, "Ruche");
    qmlRegisterSingletonInstance("com.example.ruche", 1, 0, "RucheManager", &configurateur);
    engine.rootContext()->setContextProperty("dManager", &dManager);
    engine.rootContext()->setContextProperty("rucheManager", &rucheManager);
    engine.rootContext()->setContextProperty("sensorManager", &sensorManager);
    engine.rootContext()->setContextProperty("alerteManager", &alerteManager);
    engine.rootContext()->setContextProperty("userManager", &alerteManager);


    engine.rootContext()->setContextProperty("mqttHandler", &mqttHandler);
    mqttHandler.connectToBroker();

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
