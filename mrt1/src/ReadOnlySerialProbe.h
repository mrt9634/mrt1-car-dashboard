#pragma once
#include <QObject>
#include <QString>
#include <QByteArray>
#include <QSerialPort>
#include <QSerialPortInfo>

class ReadOnlySerialProbe : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool open READ isOpen NOTIFY stateChanged)
    Q_PROPERTY(QString port READ port NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QString lastHex READ lastHex NOTIFY dataReceived)
public:
    explicit ReadOnlySerialProbe(QObject *parent=nullptr):QObject(parent){
connect(&m_serial,&QSerialPort::readyRead,this,&ReadOnlySerialProbe::readAvailable);
        connect(&m_serial,&QSerialPort::errorOccurred,this,[this](QSerialPort::SerialPortError){
            if(m_serial.error()!=QSerialPort::NoError){
                m_status=QStringLiteral("Serial error: ")+m_serial.errorString(); emit stateChanged();
            }
        });
#endif
    }

    bool isOpen() const{return m_serial.isOpen();}
    QString port() const{return m_port;}
    QString status() const{return m_status;}
    QString lastHex() const{return m_lastHex;}

    Q_INVOKABLE bool openReadOnly(const QString &portName){
        close();
        m_port=portName;
        const auto infos=QSerialPortInfo::availablePorts();
        bool valid=false;
        for(const auto &info:infos) if(info.portName()==portName || info.systemLocation()==portName) { valid=true; break; }
        if(!valid){
            m_status=QStringLiteral("Port not enumerated by QSerialPort");
            emit stateChanged();
            return false;
        }
        m_serial.setPortName(portName);
        m_serial.setBaudRate(QSerialPort::Baud115200);
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
#if 1
    void readAvailable(){
        const QByteArray data=m_serial.readAll();
        if(data.isEmpty()) return;
        m_lastHex=data.toHex(' ').toUpper();
        emit dataReceived();
    }
#endif

private:
    QSerialPort m_serial;
    QString m_port;
    QString m_status=QStringLiteral("Closed");
    QString m_lastHex;
};
