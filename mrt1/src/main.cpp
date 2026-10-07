#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include "VehicleDataProvider.h"
#include "VehicleDataBackend.h"
#include "LocalDatabase.h"
#include "SetupManager.h"

int main(int argc,char *argv[])
{
    QGuiApplication app(argc,argv);
    QCoreApplication::setApplicationName("MRT1");
    QCoreApplication::setApplicationVersion("0.1.0");
    QCoreApplication::setOrganizationName("MRT");
    LocalDatabase database;
    database.initialize();
    VehicleDataProvider vehicleData;
    VehicleDataBackend vehicleBackend(&vehicleData);
    vehicleBackend.setDisconnected();
    SetupManager setupManager;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("vehicleData",&vehicleData);
    engine.rootContext()->setContextProperty("vehicleBackend",&vehicleBackend);
    engine.rootContext()->setContextProperty("setupManager",&setupManager);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MRT1/qml/Main.qml")));
    if(engine.rootObjects().isEmpty()) return -1;
    return app.exec();
}
