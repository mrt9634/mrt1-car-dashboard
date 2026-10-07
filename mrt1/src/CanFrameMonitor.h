#pragma once
#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QDateTime>
#include <QString>
#include <QVector>

class CanFrameMonitor : public QObject {
 Q_OBJECT
 Q_PROPERTY(QVariantList frames READ frames NOTIFY changed)
 Q_PROPERTY(bool capturing READ capturing NOTIFY changed)
 Q_PROPERTY(int frameCount READ frameCount NOTIFY changed)
 Q_PROPERTY(QString status READ status NOTIFY changed)
 Q_PROPERTY(QStringList ports READ ports NOTIFY changed)
 Q_PROPERTY(int selectedPort READ selectedPort NOTIFY changed)
 Q_PROPERTY(int selectedBaud READ selectedBaud NOTIFY changed)
public:
 explicit CanFrameMonitor(QObject* p=nullptr):QObject(p){}
 QVariantList frames() const{return m_frames;}
 bool capturing() const{return m_capturing;}
 int frameCount() const{return m_frames.size();}
 QString status() const{return m_status;}
 QStringList ports() const { QStringList p; for(const auto &f:m_frames){QString v=f.toMap().value("port").toString(); if(!v.isEmpty()&&!p.contains(v))p<<v;} return p; }
 int selectedPort() const{return m_selectedPort;}
 int selectedBaud() const{return m_selectedBaud;}
 Q_INVOKABLE void start(){m_capturing=true;m_status="CAPTURE ACTIVE (read-only)";emit changed();}
 Q_INVOKABLE void stop(){m_capturing=false;m_status="CAPTURE STOPPED";emit changed();}
 Q_INVOKABLE void clear(){m_frames.clear();m_status="BUFFER CLEARED";emit changed();}
 Q_INVOKABLE void setSelection(int portIndex,int baud){m_selectedPort=portIndex;m_selectedBaud=baud;m_status="Capture filter configured";emit changed();}
 Q_INVOKABLE void acceptRawFrame(const QString &port,int baud,const QByteArray &data){
  if(!m_capturing||data.isEmpty()) return;
  QVariantMap f;
  f["time"]=QDateTime::currentDateTime().toString(Qt::ISODateWithMs);
  f["port"]=port; f["baud"]=baud; f["hex"]=QString::fromLatin1(data.toHex(' ').toUpper());
  m_frames.prepend(f); while(m_frames.size()>100)m_frames.removeLast();
  emit changed();
 }
signals:void changed();
private: QVariantList m_frames; bool m_capturing=false; int m_selectedPort=0; int m_selectedBaud=115200; QString m_status="READY — no CAN bytes captured";
};