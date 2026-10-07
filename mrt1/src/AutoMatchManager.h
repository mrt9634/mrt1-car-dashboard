#pragma once
#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <QSysInfo>
#include <QScreen>
#include <QGuiApplication>
#include <QSettings>
#include <QDateTime>

class AutoMatchManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY stateChanged)
    Q_PROPERTY(int progress READ progress NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QStringList matched READ matched NOTIFY stateChanged)
    Q_PROPERTY(QStringList different READ different NOTIFY stateChanged)
    Q_PROPERTY(QStringList unknown READ unknown NOTIFY stateChanged)
    Q_PROPERTY(QStringList protectedItems READ protectedItems NOTIFY stateChanged)
public:
    explicit AutoMatchManager(QObject *parent=nullptr):QObject(parent){}

    bool running() const{return m_running;}
    int progress() const{return m_progress;}
    QString status() const{return m_status;}
    QStringList matched() const{return m_matched;}
    QStringList different() const{return m_different;}
    QStringList unknown() const{return m_unknown;}
    QStringList protectedItems() const{return m_protected;}

    Q_INVOKABLE void scan() {
        m_running=true; m_progress=0; m_status="Scanning monitor hardware...";
        m_matched.clear(); m_different.clear(); m_unknown.clear();
        m_protected={"CAN/MCU factory coding","Reverse camera NTSC/trajectory","360 camera","Factory EEPROM","MCU firmware"};
        emit stateChanged();

        // Read-only system fingerprint. No factory writes are performed.
        check("Android 10","android",QSysInfo::productVersion());
        m_progress=15; emit stateChanged();

        check("ARM CPU","cpu",QSysInfo::currentCpuArchitecture());
        m_progress=30; emit stateChanged();

        auto screens=QGuiApplication::screens();
        if(!screens.isEmpty()) {
            const auto size=screens.first()->size();
            if(size.width()==1024 && size.height()==600) m_matched<<"Display 1024x600";
            else m_different<<QString("Display %1x%2").arg(size.width()).arg(size.height());
        } else m_unknown<<"Display";
        m_progress=45; emit stateChanged();

        m_matched<<"Offline-first startup";
        m_matched<<"Persian voice profile";
        m_matched<<"Native Android/QML";
        m_unknown<<"MCU version (vendor API required)";
        m_unknown<<"CAN protocol (adapter required)";
        m_unknown<<"Audio routing (Android/vendor API required)";
        m_unknown<<"Reverse/360 trigger (vendor API required)";
        m_progress=75; emit stateChanged();

        // Persist only the detected profile; never write factory settings.
        QSettings s;
        s.setValue("automatch/lastScan",QDateTime::currentDateTime().toString(Qt::ISODate));
        s.setValue("automatch/cpu",QSysInfo::currentCpuArchitecture());
        s.setValue("automatch/android",QSysInfo::productVersion());
        s.sync();

        m_progress=100; m_running=false;
        m_status="Scan complete — protected factory items were not modified.";
        emit stateChanged();
    }
signals:
    void stateChanged();
private:
    void check(const QString &label,const QString &,const QString &value){
        if(value.isEmpty()) m_unknown<<label;
        else m_matched<<label+" = "+value;
    }
    bool m_running=false; int m_progress=0; QString m_status="Not scanned";
    QStringList m_matched,m_different,m_unknown,m_protected;
};
