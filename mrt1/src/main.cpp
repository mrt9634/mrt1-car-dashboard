#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include "VehicleDataProvider.h"
#include "LocalDatabase.h"
#include "SetupManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setApplicationName("MRT1");
    QCoreApplication::setApplicationVersion("0.1.0");
    QCoreApplication::setOrganizationName("MRT");

    LocalDatabase database;
    database.initialize();

    VehicleDataProvider vehicleData;
    SetupManager setupManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("vehicleData", &vehicleData);
    engine.rootContext()->setContextProperty("setupManager", &setupManager);

    const QUrl url(QStringLiteral("qrc:/qt/qml/MRT1/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
