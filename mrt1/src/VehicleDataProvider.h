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

public:
    explicit VehicleDataProvider(QObject *parent = nullptr)
        : QObject(parent) {}

    double speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    double coolant() const { return m_coolant; }
    bool connected() const { return m_connected; }

signals:
    void speedChanged();
    void rpmChanged();
    void coolantChanged();
    void connectedChanged();

private:
    double m_speed = 0.0;
    double m_rpm = 0.0;
    double m_coolant = 0.0;
    bool m_connected = false;
};
