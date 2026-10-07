#pragma once
#include <QObject>
#include <QString>

class FactoryDiagnostics : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString canStatus READ canStatus NOTIFY changed)
    Q_PROPERTY(QString canInterface READ canInterface NOTIFY changed)
    Q_PROPERTY(QString mcuStatus READ mcuStatus NOTIFY changed)
    Q_PROPERTY(QString mcuVersion READ mcuVersion NOTIFY changed)
    Q_PROPERTY(QString mcuModel READ mcuModel NOTIFY changed)
public:
    explicit FactoryDiagnostics(QObject *parent=nullptr):QObject(parent){}
    QString canStatus() const{return m_canStatus;}
    QString canInterface() const{return m_canInterface;}
    QString mcuStatus() const{return m_mcuStatus;}
    QString mcuVersion() const{return m_mcuVersion;}
    QString mcuModel() const{return m_mcuModel;}

    Q_INVOKABLE void setCanInfo(const QString &status,const QString &interfaceName){
        m_canStatus=status;m_canInterface=interfaceName;emit changed();
    }
    Q_INVOKABLE void setMcuInfo(const QString &status,const QString &version,const QString &model){
        m_mcuStatus=status;m_mcuVersion=version;m_mcuModel=model;emit changed();
    }
    Q_INVOKABLE void clear(){
        m_canStatus="UNKNOWN";m_canInterface="UNKNOWN";
        m_mcuStatus="UNKNOWN";m_mcuVersion="UNKNOWN";m_mcuModel="UNKNOWN";
        emit changed();
    }
signals:
    void changed();
private:
    QString m_canStatus="UNKNOWN";
    QString m_canInterface="UNKNOWN";
    QString m_mcuStatus="UNKNOWN";
    QString m_mcuVersion="UNKNOWN";
    QString m_mcuModel="UNKNOWN";
};
