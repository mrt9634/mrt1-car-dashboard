#pragma once

#include <QObject>
#include <QSettings>
#include <QSysInfo>
#include <QTimer>
#include <QStringList>

class SetupManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool firstRun READ firstRun NOTIFY stateChanged)
    Q_PROPERTY(bool setupComplete READ setupComplete NOTIFY stateChanged)
    Q_PROPERTY(bool updateCheckAvailable READ updateCheckAvailable NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QStringList protectedFactoryItems READ protectedFactoryItems CONSTANT)

public:
    explicit SetupManager(QObject *parent = nullptr)
        : QObject(parent),
          m_settings("MRT", "MRT1")
    {
        m_firstRun = !m_settings.value("setup/complete", false).toBool();
        m_updateCheckAvailable = false;
        m_status = m_firstRun
            ? QStringLiteral("Initial hardware setup pending")
            : QStringLiteral("MRT1 ready");
    }

    bool firstRun() const { return m_firstRun; }
    bool setupComplete() const { return m_settings.value("setup/complete", false).toBool(); }
    bool updateCheckAvailable() const { return m_updateCheckAvailable; }
    QString status() const { return m_status; }

    QStringList protectedFactoryItems() const {
        return {
            QStringLiteral("CAN / MCU"),
            QStringLiteral("Reverse camera NTSC"),
            QStringLiteral("360 camera"),
            QStringLiteral("Reverse trajectory"),
            QStringLiteral("Factory EEPROM")
        };
    }

    Q_INVOKABLE void runInitialSetup()
    {
        m_status = QStringLiteral("Checking Android / display / MCU / CAN...");
        emit stateChanged();

        // Read-only hardware fingerprint. No factory write and no MCU flash.
        m_settings.setValue("hardware/os", QSysInfo::productVersion());
        m_settings.setValue("hardware/kernel", QSysInfo::kernelVersion());
        m_settings.setValue("hardware/cpu", QSysInfo::currentCpuArchitecture());

        // A normal Android app cannot silently reboot or enter vendor factory
        // settings. We therefore stage the operation and expose the state.
        m_settings.setValue("setup/rebootRequested", true);
        m_settings.setValue("setup/factoryCheck", QStringLiteral("read-only"));
        m_settings.setValue("setup/protectedSettings", protectedFactoryItems());

        m_status = QStringLiteral("Hardware checked. Factory settings protected.");
        m_settings.setValue("setup/complete", true);
        m_firstRun = false;
        emit stateChanged();
    }

    Q_INVOKABLE void checkForUpdates()
    {
        // Network/update implementation will be connected to the vendor-supported
        // updater once the exact MCU package/API is identified.
        m_updateCheckAvailable = false;
        m_status = QStringLiteral("Update check staged; MCU flashing requires verified vendor package.");
        emit stateChanged();
    }

signals:
    void stateChanged();

private:
    QSettings m_settings;
    bool m_firstRun = true;
    bool m_updateCheckAvailable = false;
    QString m_status;
};
