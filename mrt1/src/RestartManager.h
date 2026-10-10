#pragma once

#include <QObject>
#include <QCoreApplication>
#include <QTimer>

#ifdef Q_OS_ANDROID
#include <QJniObject>
#endif

class RestartManager : public QObject
{
    Q_OBJECT
public:
    explicit RestartManager(QObject *parent = nullptr)
        : QObject(parent) {}

    Q_INVOKABLE void restartApp()
    {
#ifdef Q_OS_ANDROID
        try {
            QJniObject activity = QJniObject::callStaticObjectMethod(
                "org/qtproject/qt/android/QtNative",
                "activity",
                "()Landroid/app/Activity;");

            if (!activity.isValid()) {
                QCoreApplication::quit();
                return;
            }

            QJniObject packageName = activity.callObjectMethod(
                "getPackageName", "()Ljava/lang/String;");

            QJniObject componentName(
                "android/content/ComponentName",
                "(Ljava/lang/String;Ljava/lang/String;)V",
                packageName.object<jstring>(),
                QJniObject::fromString(
                    "org.qtproject.qt.android.bindings.QtActivity"
                ).object<jstring>());

            QJniObject launchIntent(
                "android/content/Intent",
                "()V");

            launchIntent.callObjectMethod(
                "setComponent",
                "(Landroid/content/ComponentName;)Landroid/content/Intent;",
                componentName.object());

            launchIntent.callObjectMethod(
                "addFlags",
                "(I)Landroid/content/Intent;",
                0x10008000);

            activity.callMethod<void>(
                "startActivity",
                "(Landroid/content/Intent;)V",
                launchIntent.object());

            QTimer::singleShot(400, []() {
                QCoreApplication::exit(0);
            });
        } catch (...) {
            QCoreApplication::quit();
        }
#else
        QCoreApplication::quit();
#endif
    }

    Q_INVOKABLE void shutdownApp()
    {
        QCoreApplication::quit();
    }
};
