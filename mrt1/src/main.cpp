#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include "VehicleDataProvider.h"
#include "VehicleDataBackend.h"
#include "CanProvider.h"
#include "ObdProvider.h"
#include "SpeechManager.h"
#include "FactoryDiagnostics.h"
#include "HardwareProbe.h"
#include "LocalDatabase.h"
#include "SetupManager.h"

int main(int argc,char *argv[])
{
    QGuiApplication app(argc,argv);
    QCoreApplication::setApplicationName("MRT1");
    QCoreApplication::setApplicationVersion("0.1.0");
    QCoreApplication::setOrganizationName("MRT");

    LocalDatabase database; database.initialize();
    VehicleDataProvider vehicleData;
    VehicleDataBackend vehicleBackend(&vehicleData);
    CanProvider canProvider(&vehicleData);
    ObdProvider obdProvider(&vehicleData);
    SpeechManager speechManager;
    FactoryDiagnostics factoryDiagnostics;
    HardwareProbe hardwareProbe;

    vehicleBackend.setDisconnected();
    canProvider.setOffline();
    obdProvider.setOffline();
    factoryDiagnostics.clear();

    QQmlApplicationEngine engine;
    auto *ctx=engine.rootContext();
    ctx->setContextProperty("vehicleData",&vehicleData);
    ctx->setContextProperty("vehicleBackend",&vehicleBackend);
    ctx->setContextProperty("canProvider",&canProvider);
    ctx->setContextProperty("obdProvider",&obdProvider);
    ctx->setContextProperty("speechManager",&speechManager);
    ctx->setContextProperty("factoryDiagnostics",&factoryDiagnostics);
    ctx->setContextProperty("hardwareProbe",&hardwareProbe);
    ctx->setContextProperty("setupManager",&setupManager);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MRT1/qml/Main.qml")));
    if(engine.rootObjects().isEmpty()) return -1;
    return app.exec();
}
