#pragma once
#include <QObject>
#include <QStringList>
#include <QFileInfo>

class HardwareProbe : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY changed)
    Q_PROPERTY(QStringList candidates READ candidates NOTIFY changed)
public:
    explicit HardwareProbe(QObject *parent=nullptr):QObject(parent){}

    QString status() const{return m_status;}
    QStringList candidates() const{return m_candidates;}

    Q_INVOKABLE void scanReadOnly(){
        m_candidates.clear();
        const QStringList paths={
            "/dev/ttyS0","/dev/ttyS1","/dev/ttyS2","/dev/ttyS3","/dev/ttyS4","/dev/ttyS5",
            "/dev/ttyHS0","/dev/ttyHS1","/dev/ttyHS2","/dev/ttyHS3",
            "/dev/ttyMT0","/dev/ttyMT1","/dev/ttyMT2",
            "/dev/ttyUSB0","/dev/ttyUSB1","/dev/ttyUSB2",
            "/dev/ttyACM0","/dev/ttyACM1","/dev/ttyAMA0"
        };
        for(const auto &p:paths) if(QFileInfo::exists(p)) m_candidates.append(p);
        m_status=m_candidates.isEmpty()
            ? QStringLiteral("No candidate CAN/MCU interface found")
            : QStringLiteral("Read-only interface candidates found — no data has been written");
        emit changed();
    }

signals:
    void changed();

private:
    QString m_status=QStringLiteral("Not scanned");
    QStringList m_candidates;
};
