#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "administrateur.h"
#include "dataexporter.h"
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

    Administrateur admin;
    dataExporter dExport;
    configurateurRuche configurateur;
    MqttHandler mqttHandler(&configurateur);

    qmlRegisterType<Ruche>("com.example.ruche", 1, 0, "Ruche");
    qmlRegisterSingletonInstance("com.example.ruche", 1, 0, "RucheManager", &configurateur);


    engine.rootContext()->setContextProperty("admin", &admin);
    engine.rootContext()->setContextProperty("dExport", &dExport);
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
