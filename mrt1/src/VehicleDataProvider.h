#pragma once
#include <QObject>
#include <QVariantMap>
#include <QString>

class VehicleDataProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(double coolant READ coolant NOTIFY coolantChanged)
    Q_PROPERTY(double fuel READ fuel NOTIFY fuelChanged)
    Q_PROPERTY(double batteryVoltage READ batteryVoltage NOTIFY batteryVoltageChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString source READ source NOTIFY sourceChanged)

public:
    explicit VehicleDataProvider(QObject *parent=nullptr):QObject(parent){}

    double speed() const{return m_speed;}
    double rpm() const{return m_rpm;}
    double coolant() const{return m_coolant;}
    double fuel() const{return m_fuel;}
    double batteryVoltage() const{return m_batteryVoltage;}
    bool connected() const{return m_connected;}
    QString source() const{return m_source;}

    // Production rule: values stay unavailable until a real vehicle backend supplies them.
    Q_INVOKABLE void setVehicleData(const QVariantMap &data){
        bool changed=false;
        if(data.contains("speed") && m_speed!=data.value("speed").toDouble()){m_speed=data.value("speed").toDouble();emit speedChanged();changed=true;}
        if(data.contains("rpm") && m_rpm!=data.value("rpm").toDouble()){m_rpm=data.value("rpm").toDouble();emit rpmChanged();changed=true;}
        if(data.contains("coolant") && m_coolant!=data.value("coolant").toDouble()){m_coolant=data.value("coolant").toDouble();emit coolantChanged();changed=true;}
        if(data.contains("fuel") && m_fuel!=data.value("fuel").toDouble()){m_fuel=data.value("fuel").toDouble();emit fuelChanged();changed=true;}
        if(data.contains("batteryVoltage") && m_batteryVoltage!=data.value("batteryVoltage").toDouble()){m_batteryVoltage=data.value("batteryVoltage").toDouble();emit batteryVoltageChanged();changed=true;}
        if(data.contains("connected") && m_connected!=data.value("connected").toBool()){m_connected=data.value("connected").toBool();emit connectedChanged();changed=true;}
        if(data.contains("source") && m_source!=data.value("source").toString()){m_source=data.value("source").toString();emit sourceChanged();changed=true;}
        Q_UNUSED(changed)
    }

signals:
    void speedChanged(); void rpmChanged(); void coolantChanged(); void fuelChanged();
    void batteryVoltageChanged(); void connectedChanged(); void sourceChanged();

private:
    double m_speed=0, m_rpm=0, m_coolant=0, m_fuel=0, m_batteryVoltage=0;
    bool m_connected=false;
    QString m_source=QStringLiteral("NONE");
};
