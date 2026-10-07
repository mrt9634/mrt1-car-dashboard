#pragma once

#include <QObject>
#include <QVariantMap>

class VehicleDataProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(double coolant READ coolant NOTIFY coolantChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(double fuel READ fuel NOTIFY fuelChanged)
    Q_PROPERTY(double batteryVoltage READ batteryVoltage NOTIFY batteryVoltageChanged)

public:
    explicit VehicleDataProvider(QObject *parent = nullptr)
        : QObject(parent) {}

    double speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    double coolant() const { return m_coolant; }
    bool connected() const { return m_connected; }
    double fuel() const { return m_fuel; }
    double batteryVoltage() const { return m_batteryVoltage; }

signals:
    void speedChanged();
    void rpmChanged();
    void coolantChanged();
    void connectedChanged();
    void fuelChanged();
    void batteryVoltageChanged();

private:
    double m_speed = 0.0;
    double m_rpm = 0.0;
    double m_coolant = 0.0;
    bool m_connected = false;
    double m_fuel = 0.0;
    double m_batteryVoltage = 0.0;
};
