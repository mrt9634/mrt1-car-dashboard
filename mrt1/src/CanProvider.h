#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>

class VehicleDataProvider;

class CanProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY stateChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName CONSTANT)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)

public:
    explicit CanProvider(VehicleDataProvider *vehicle,QObject *parent=nullptr)
        : QObject(parent),m_vehicle(vehicle){}

    bool connected() const{return m_connected;}
    QString interfaceName() const{return m_interface;}
    QString status() const{return m_status;}

    Q_INVOKABLE void setInterface(const QString &name){m_interface=name;m_status=QStringLiteral("Interface configured: ")+name;emit stateChanged();}
    Q_INVOKABLE void setOffline(){m_connected=false;m_status=QStringLiteral("CAN offline");emit stateChanged();}
    Q_INVOKABLE void acceptFrame(const QVariantMap &signals){
        // Generic signal layer. Vendor-specific CAN decoding belongs in an adapter.
        if(signals.isEmpty()) return;
        m_connected=true;
        m_status=QStringLiteral("CAN data received");
        m_vehicle->setVehicleData(signals);
        emit stateChanged();
    }

signals:
    void stateChanged();

private:
    VehicleDataProvider *m_vehicle;
    bool m_connected=false;
    QString m_interface=QStringLiteral("AUTO");
    QString m_status=QStringLiteral("CAN offline");
};
