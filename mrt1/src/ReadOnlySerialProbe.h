#pragma once
#include <QObject>
#include <QString>
#include <QByteArray>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QDateTime>
#include "CanFrameMonitor.h"

class ReadOnlySerialProbe : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool open READ isOpen NOTIFY stateChanged)
    Q_PROPERTY(QString port READ port NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QString lastHex READ lastHex NOTIFY dataReceived)
    Q_PROPERTY(QString timestamp READ timestamp NOTIFY dataReceived)
    Q_PROPERTY(int baud READ baud NOTIFY stateChanged)
public:
    explicit ReadOnlySerialProbe(QObject *parent=nullptr):QObject(parent){
connect(&m_serial,&QSerialPort::readyRead,this,&ReadOnlySerialProbe::readAvailable);
        connect(&m_serial,&QSerialPort::errorOccurred,this,[this](QSerialPort::SerialPortError){
            if(m_serial.error()!=QSerialPort::NoError){
                m_status=QStringLiteral("Serial error: ")+m_serial.errorString(); emit stateChanged();
            }
        });
    }

    bool isOpen() const{return m_serial.isOpen();}
    QString port() const{return m_port;}
    QString status() const{return m_status;}
    QString lastHex() const{return m_lastHex;}
    QString timestamp() const{return m_timestamp;}
    int baud() const{return m_baud;}

    Q_INVOKABLE bool openReadOnly(const QString &portName, int baudRate=115200){
        close();
        m_port=portName;
        m_baud=baudRate;
        const auto infos=QSerialPortInfo::availablePorts();
        bool valid=false;
        for(const auto &info:infos) if(info.portName()==portName || info.systemLocation()==portName) { valid=true; break; }
        if(!valid){
            m_status=QStringLiteral("Port not enumerated by QSerialPort");
            emit stateChanged();
            return false;
        }
        m_serial.setPortName(portName);
        m_serial.setBaudRate(baudRate);
        m_serial.setDataBits(QSerialPort::Data8);
        m_serial.setParity(QSerialPort::NoParity);
        m_serial.setStopBits(QSerialPort::OneStop);
        m_serial.setFlowControl(QSerialPort::NoFlowControl);
        m_serial.setReadBufferSize(4096);
        // Deliberately open without writing any bytes.
        if(!m_serial.open(QIODevice::ReadOnly)){
            m_status=QStringLiteral("Open failed: ")+m_serial.errorString();
            emit stateChanged();
            return false;
        }
        m_status=QStringLiteral("READ ONLY: listening");
        emit stateChanged();
        return true;
    }

    Q_INVOKABLE void close(){
        if(m_serial.isOpen()) m_serial.close();
        m_status=QStringLiteral("Closed");
        emit stateChanged();
    }

signals:
    void stateChanged();
    void dataReceived();

private slots:
    void readAvailable(){
        const QByteArray data=m_serial.readAll();
        if(data.isEmpty()) return;
        m_lastHex=data.toHex(' ').toUpper();
        m_timestamp=QDateTime::currentDateTime().toString(Qt::ISODateWithMs);
        if (m_monitor) m_monitor->acceptRawFrame(m_port, m_baud, data);
        emit dataReceived();
    }

public:
    void setMonitor(CanFrameMonitor *monitor) { m_monitor = monitor; }

private:
    QSerialPort m_serial;
    QString m_port;
    QString m_status=QStringLiteral("Closed");
    QString m_lastHex;
    QString m_timestamp;
    int m_baud=115200;
    CanFrameMonitor *m_monitor=nullptr;
};
