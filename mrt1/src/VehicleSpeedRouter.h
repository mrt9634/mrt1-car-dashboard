#pragma once
#include <QObject>
#include <QString>

class VehicleSpeedRouter : public QObject {
    Q_OBJECT
    Q_PROPERTY(double displaySpeedKmh READ displaySpeedKmh NOTIFY displayChanged)
    Q_PROPERTY(QString source READ source NOTIFY displayChanged)
public:
    explicit VehicleSpeedRouter(QObject *parent=nullptr):QObject(parent){}
    double displaySpeedKmh() const{return m_speed;}
    QString source() const{return m_source;}

    Q_INVOKABLE void update(double canSpeed,double gpsSpeed,bool canConnected,bool gpsAvailable) {
        if(canConnected && canSpeed>=0.0) { set(canSpeed,"CAN"); return; }
        if(gpsAvailable && gpsSpeed>=0.0) { set(gpsSpeed,"GPS"); return; }
        set(-1.0,"NONE");
    }
signals:
    void displayChanged();
private:
    void set(double s,const QString &src){if(m_speed==s&&m_source==src)return;m_speed=s;m_source=src;emit displayChanged();}
    double m_speed=-1.0; QString m_source="NONE";
};
