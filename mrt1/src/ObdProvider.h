#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>

class ObdProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
public:
    explicit ObdProvider(QObject *parent=nullptr):QObject(parent){}
    bool connected() const{return m_connected;}
    QString status() const{return m_status;}
    Q_INVOKABLE void setOffline(){m_connected=false;m_status="OFFLINE";emit stateChanged();}
    Q_INVOKABLE void acceptPidData(const QVariantMap &data){m_connected=true;m_status="ONLINE";emit stateChanged();emit pidData(data);}
signals:
    void stateChanged();
    void pidData(const QVariantMap &data);
private:
    bool m_connected=false; QString m_status="OFFLINE";
};
