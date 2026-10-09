#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDebug>
#include <QTimer>

#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <jni.h>
#include <android/log.h>
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  "MRT1_DEBUG", __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "MRT1_DEBUG", __VA_ARGS__)
#else
#define LOGI(...) qInfo() << __VA_ARGS__
#define LOGE(...) qCritical() << __VA_ARGS__
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

extern "C" JNIEXPORT void JNICALL
Java_com_mrt_jarvis_SpeechBridge_nativeTtsDone(JNIEnv *, jclass) {
    LOGI("JNI: nativeTtsDone");
    if (!gSpeechManager) return;
    QMetaObject::invokeMethod(gSpeechManager, "acceptTtsDone", Qt::QueuedConnection);
}

extern "C" JNIEXPORT void JNICALL
Java_com_mrt_jarvis_SpeechBridge_nativeResult(JNIEnv *env, jclass, jstring value) {
    Q_UNUSED(env);
    LOGI("JNI: nativeResult called");
    if (!gSpeechManager) return;
    QJniObject text(value);
    QMetaObject::invokeMethod(gSpeechManager, "acceptRecognition", Qt::QueuedConnection,
                              Q_ARG(QString, text.toString()));
}
#endif

int main(int argc, char *argv[])
{
    LOGI("=== MRT1 STARTUP BEGIN ===");

    QGuiApplication app(argc, argv);
    LOGI("STEP 1: QGuiApplication created");

    QCoreApplication::setApplicationName("MRT1");
    QCoreApplication::setApplicationVersion("0.1.0");
    QCoreApplication::setOrganizationName("MRT");
    LOGI("STEP 2: App metadata set");

    LOGI("STEP 3: Initializing LocalDatabase...");
    LocalDatabase database;
    const bool dbOk = database.initialize();
    LOGI("STEP 3: Database initialized = %d", dbOk);

    LOGI("STEP 4: Creating providers...");
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
    LOGI("STEP 4: All providers created");

    LOGI("STEP 5: Setting initial states...");
    vehicleBackend.setDisconnected();
    canProvider.setOffline();
    obdProvider.setOffline();
    factoryDiagnostics.clear();
    LOGI("STEP 5: Initial states set");

    LOGI("STEP 6: Creating QQmlApplicationEngine...");
    QQmlApplicationEngine engine;

    // Catch QML errors
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
        LOGE("QML object creation FAILED");
    }, Qt::QueuedConnection);
    LOGI("STEP 6: Engine created");

    LOGI("STEP 7: Setting context properties...");
    auto *ctx = engine.rootContext();
    ctx->setContextProperty("vehicleData",      &vehicleData);
    ctx->setContextProperty("vehicleBackend",   &vehicleBackend);
    ctx->setContextProperty("canProvider",      &canProvider);
    ctx->setContextProperty("obdProvider",      &obdProvider);
    ctx->setContextProperty("speechManager",    &speechManager);
    ctx->setContextProperty("factoryDiagnostics",&factoryDiagnostics);
    ctx->setContextProperty("hardwareProbe",    &hardwareProbe);
    ctx->setContextProperty("serialProbe",      &serialProbe);
    ctx->setContextProperty("autoMatch",        &autoMatch);
    ctx->setContextProperty("gpsSpeed",         &gpsSpeed);
    ctx->setContextProperty("speedRouter",      &speedRouter);
    ctx->setContextProperty("openai",           &openai);
    ctx->setContextProperty("setupManager",     &setupManager);
    ctx->setContextProperty("canFrameMonitor",  &canFrameMonitor);
    ctx->setContextProperty("canDecoder",       &canDecoder);
    ctx->setContextProperty("localMusic",       &localMusic);
    ctx->setContextProperty("phoneManager",     &phoneManager);
    LOGI("STEP 7: All context properties set");

    const QUrl mainUrl(QStringLiteral("qrc:/qt/qml/MRT1/qml/Main.qml"));
    LOGI("STEP 8: Loading QML: %s", mainUrl.toString().toUtf8().constData());

    engine.load(mainUrl);

    LOGI("STEP 9: engine.load() returned");
    LOGI("STEP 9: rootObjects().size() = %d", engine.rootObjects().size());

    if (engine.rootObjects().isEmpty()) {
        LOGE("STEP 9: rootObjects is EMPTY — QML failed to load!");
        return -1;
    }

    LOGI("STEP 10: QML loaded successfully. Entering event loop...");
    LOGI("=== MRT1 STARTUP COMPLETE ===");

    return app.exec();
}
