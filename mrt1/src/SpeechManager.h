#pragma once
#include <QObject>
#include <QString>

class SpeechManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool listening READ listening NOTIFY stateChanged)
    Q_PROPERTY(bool speaking READ speaking NOTIFY stateChanged)
    Q_PROPERTY(QString locale READ locale CONSTANT)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
public:
    explicit SpeechManager(QObject *parent=nullptr):QObject(parent){}
    bool listening() const{return m_listening;}
    bool speaking() const{return m_speaking;}
    QString locale() const{return QStringLiteral("fa-IR");}
    QString status() const{return m_status;}

    Q_INVOKABLE void startListening(){m_listening=true;m_status=QStringLiteral("Listening: Persian");emit stateChanged();}
    Q_INVOKABLE void stopListening(){m_listening=false;m_status=QStringLiteral("Listening stopped");emit stateChanged();}
    Q_INVOKABLE void speak(const QString &text){
        if(text.trimmed().isEmpty()) return;
        m_speaking=true;m_status=QStringLiteral("Speaking: Persian");m_lastText=text;emit stateChanged();
        // Native Android TTS/STT adapter is intentionally isolated from the core.
        m_speaking=false;emit stateChanged();
    }
    Q_INVOKABLE void acceptRecognition(const QString &text){
        if(text.trimmed().isEmpty()) return;
        m_lastText=text;m_status=QStringLiteral("Recognized");emit recognized(text);emit stateChanged();
    }
signals:
    void recognized(const QString &text);
    void stateChanged();
private:
    bool m_listening=false;
    bool m_speaking=false;
    QString m_status=QStringLiteral("Persian voice ready");
    QString m_lastText;
};
