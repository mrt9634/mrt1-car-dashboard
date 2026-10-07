#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QByteArray>

class CanSignalDecoder : public QObject {
 Q_OBJECT
 Q_PROPERTY(QString status READ status NOTIFY changed)
 Q_PROPERTY(QString protocol READ protocol NOTIFY changed)
public:
 explicit CanSignalDecoder(QObject* p=nullptr):QObject(p){}
 QString status()const{return m_status;}
 QString protocol()const{return m_protocol;}
 Q_INVOKABLE QVariantMap inspect(const QByteArray &frame){
  QVariantMap out;
  if(frame.isEmpty()){m_status="EMPTY";emit changed();return out;}
  out["length"]=frame.size();
  out["hex"]=QString::fromLatin1(frame.toHex(' ').toUpper());
  out["note"]=QStringLiteral("Raw frame inspected; Peugeot signal mapping is not assumed.");
  m_status=QStringLiteral("RAW FRAME READY");
  emit changed();
  return out;
 }
 Q_INVOKABLE void setProtocol(const QString &p){m_protocol=p;m_status="Protocol selected: "+p;emit changed();}
signals:void changed();
private:QString m_status="NO DECODER";QString m_protocol="AUTO / UNKNOWN";
};