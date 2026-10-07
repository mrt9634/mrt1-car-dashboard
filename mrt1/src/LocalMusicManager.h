#pragma once
#include <QObject>
#include <QVariantList>
#include <QUrl>
#include <QDirIterator>
#include <QFileInfo>

class LocalMusicManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList tracks READ tracks NOTIFY changed)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY changed)
    Q_PROPERTY(bool playing READ playing NOTIFY changed)
    Q_PROPERTY(QString status READ status NOTIFY changed)
public:
    explicit LocalMusicManager(QObject *p=nullptr):QObject(p){}
    QVariantList tracks() const{return m_tracks;}
    int currentIndex() const{return m_index;}
    bool playing() const{return m_playing;}
    QString status() const{return m_status;}

    Q_INVOKABLE void scan(const QString &root=QString()) {
        m_tracks.clear();
        QString base=root.trimmed();
#ifdef Q_OS_ANDROID
        if(base.isEmpty()) base="/sdcard/Music";
#endif
        if(base.isEmpty()) {m_status="Select a local music folder";emit changed();return;}
        QDirIterator it(base, QStringList()<<"*.mp3"<<"*.m4a"<<"*.aac"<<"*.wav"<<"*.ogg"<<"*.flac",
                        QDir::Files, QDirIterator::Subdirectories);
        while(it.hasNext() && m_tracks.size()<500) {
            const QString path=it.next();
            QVariantMap t; t["title"]=QFileInfo(path).completeBaseName(); t["url"]=QUrl::fromLocalFile(path).toString();
            m_tracks.append(t);
        }
        m_status=m_tracks.isEmpty()?"No local tracks found":"Found "+QString::number(m_tracks.size())+" local tracks";
        m_index=m_tracks.isEmpty()?-1:0; m_playing=false; emit changed();
    }
    Q_INVOKABLE void select(int index){if(index<0||index>=m_tracks.size())return;m_index=index;m_playing=false;emit changed();}
    Q_INVOKABLE void setPlaying(bool v){if(m_index<0)return;m_playing=v;emit changed();}
    Q_INVOKABLE void stop(){m_playing=false;emit changed();}
signals:void changed();
private: QVariantList m_tracks; int m_index=-1; bool m_playing=false; QString m_status="Not scanned";
};