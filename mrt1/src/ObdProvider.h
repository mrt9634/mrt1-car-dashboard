#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>
#include "VehicleDataProvider.h"

class ObdProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
public:
    explicit ObdProvider(VehicleDataProvider *vehicle,QObject *parent=nullptr):QObject(parent),m_vehicle(vehicle){}
    bool connected() const{return m_connected;}
    QString status() const{return m_status;}

    Q_INVOKABLE void setOffline(){m_connected=false;m_status=QStringLiteral("OBD offline");emit stateChanged();}
    Q_INVOKABLE void acceptPidData(const QVariantMap &data){
        if(data.isEmpty())return;
        m_connected=true;
        m_status=QStringLiteral("OBD-II data received");
        m_vehicle->setVehicleData(data);
        emit stateChanged();
    }
signals: void stateChanged();
private:
    VehicleDataProvider *m_vehicle;
    bool m_connected=false;
    QString m_status=QStringLiteral("OBD offline");
};
