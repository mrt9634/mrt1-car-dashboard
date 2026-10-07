#pragma once
#include <QObject>
#include <QGeoPositionInfoSource>
#include <QGeoPositionInfo>
#include <QVariant>
#include <cmath>

class GpsSpeedProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY stateChanged)
    Q_PROPERTY(double speedKmh READ speedKmh NOTIFY speedChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
public:
    explicit GpsSpeedProvider(QObject *parent=nullptr):QObject(parent) {
        m_source=QGeoPositionInfoSource::createDefaultSource(this);
        if(m_source) {
            m_source->setUpdateInterval(500);
            connect(m_source,&QGeoPositionInfoSource::positionUpdated,this,&GpsSpeedProvider::positionUpdated);
            connect(m_source,&QGeoPositionInfoSource::errorOccurred,this,[this](QGeoPositionInfoSource::Error){
                m_status="GPS error"; emit stateChanged();
            });
        } else m_status="GPS unavailable";
    }
    bool available() const{return m_available;}
    double speedKmh() const{return m_speedKmh;}
    QString status() const{return m_status;}

    Q_INVOKABLE void start(){ if(!m_source){m_status="GPS unavailable";emit stateChanged();return;} m_source->startUpdates(); m_status="GPS active"; emit stateChanged(); }
    Q_INVOKABLE void stop(){ if(m_source)m_source->stopUpdates(); m_status="GPS stopped"; emit stateChanged(); }

signals:
    void stateChanged();
    void speedChanged();

private slots:
    void positionUpdated(const QGeoPositionInfo &info) {
        m_available=true;
        const double mps=info.attribute(QGeoPositionInfo::GroundSpeed);
        if(std::isfinite(mps) && mps>=0.0) {
            const double kmh=mps*3.6;
            if(std::abs(kmh-m_speedKmh)>=0.2) { m_speedKmh=kmh; emit speedChanged(); }
            m_status="GPS speed available";
        } else m_status="GPS position available; speed unavailable";
        emit stateChanged();
    }
private:
    QGeoPositionInfoSource *m_source=nullptr;
    bool m_available=false;
    double m_speedKmh=0.0;
    QString m_status="GPS not started";
};
