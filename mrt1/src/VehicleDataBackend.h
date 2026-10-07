#pragma once
#include <QObject>
#include "VehicleDataProvider.h"

class VehicleDataBackend : public QObject
{
    Q_OBJECT
public:
    explicit VehicleDataBackend(VehicleDataProvider *provider,QObject *parent=nullptr):QObject(parent),m_provider(provider){}
    Q_INVOKABLE void setDisconnected(const QString &reason=QStringLiteral("No vehicle backend connected")){
        m_provider->setVehicleData({{"connected",false},{"source",reason}});
    }
private:
    VehicleDataProvider *m_provider;
};
