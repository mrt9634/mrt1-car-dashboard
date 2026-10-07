#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <jni.h>
#endif
#include "VehicleDataProvider.h"
#include "VehicleDataBackend.h"
#include "CanProvider.h"
#include "ObdProvider.h"
#include "SpeechManager.h"
#include "FactoryDiagnostics.h"
#include "HardwareProbe.h"
#include "ReadOnlySerialProbe.h"
#include "AutoMatchManager.h"
#include "GpsSpeedProvider.h"
#include "VehicleSpeedRouter.h"
#include "OpenAIManager.h"
#include "LocalDatabase.h"
#include "SetupManager.h"
#include "CanFrameMonitor.h"
#include "CanSignalDecoder.h"
#include "LocalMusicManager.h"
#include "PhoneManager.h"

#ifdef Q_OS_ANDROID
static SpeechManager *gSpeechManager = nullptr;
extern "C" JNIEXPORT void JNICALL Java_com_mrt_jarvis_SpeechBridge_nativeTtsDone(JNIEnv *, jclass) {
    if (!gSpeechManager) return;
    QMetaObject::invokeMethod(gSpeechManager, "acceptTtsDone", Qt::QueuedConnection);
}
extern "C" JNIEXPORT void JNICALL Java_com_mrt_jarvis_SpeechBridge_nativeResult(JNIEnv *env, jclass, jstring value) {
    Q_UNUSED(env);
    if (!gSpeechManager) return;
    QJniObject text(value);
    QMetaObject::invokeMethod(gSpeechManager, "acceptRecognition", Qt::QueuedConnection,
                              Q_ARG(QString, text.toString()));
}
#endif

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
#ifdef Q_OS_ANDROID
    gSpeechManager = &speechManager;
#endif
    FactoryDiagnostics factoryDiagnostics;
    HardwareProbe hardwareProbe;
    ReadOnlySerialProbe serialProbe;
    CanFrameMonitor canFrameMonitor;
    CanSignalDecoder canDecoder;
    LocalMusicManager localMusic;
    PhoneManager phoneManager;
    serialProbe.setMonitor(&canFrameMonitor);
    AutoMatchManager autoMatch;
    GpsSpeedProvider gpsSpeed;
    VehicleSpeedRouter speedRouter;
    OpenAIManager openai;
    SetupManager setupManager;

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
    ctx->setContextProperty("serialProbe",&serialProbe);
    ctx->setContextProperty("autoMatch",&autoMatch);
    ctx->setContextProperty("gpsSpeed",&gpsSpeed);
    ctx->setContextProperty("speedRouter",&speedRouter);
    ctx->setContextProperty("openai",&openai);
    ctx->setContextProperty("setupManager",&setupManager);
    ctx->setContextProperty("canFrameMonitor",&canFrameMonitor);
    ctx->setContextProperty("canDecoder",&canDecoder);
    ctx->setContextProperty("localMusic",&localMusic);
    ctx->setContextProperty("phoneManager",&phoneManager);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MRT1/qml/Main.qml")));
    if(engine.rootObjects().isEmpty()) return -1;
    return app.exec();
}
