#pragma once
#include <QObject>
#include <QString>
#include <QTimer>

class SpeechManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool listening READ listening NOTIFY stateChanged)
    Q_PROPERTY(bool speaking READ speaking NOTIFY stateChanged)
    Q_PROPERTY(QString locale READ locale WRITE setLocale NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QString recognizedText READ recognizedText NOTIFY recognizedTextChanged)
public:
    explicit SpeechManager(QObject *parent=nullptr):QObject(parent){}
    bool listening() const{return m_listening;}
    bool speaking() const{return m_speaking;}
    QString locale() const{return m_locale;}
    QString status() const{return m_status;}
    QString recognizedText() const{return m_recognized;}

    void setLocale(const QString &v){m_locale=v.trimmed().isEmpty()?"fa-IR":v.trimmed();emit stateChanged();}
    Q_INVOKABLE void startListening(){m_listening=true;m_status="Listening — Persian";emit stateChanged();}
    Q_INVOKABLE void stopListening(){m_listening=false;m_status="Ready";emit stateChanged();}
    Q_INVOKABLE void speak(const QString &text){if(text.trimmed().isEmpty())return;m_speaking=true;m_status="Speaking — Persian";emit stateChanged();QTimer::singleShot(1200,this,[this](){m_speaking=false;m_status="Ready";emit stateChanged();});}
    Q_INVOKABLE void acceptRecognition(const QString &text){m_recognized=text.trimmed();m_listening=false;m_status=m_recognized.isEmpty()?"No speech recognized":"Speech recognized";emit recognizedTextChanged();emit stateChanged();}
signals:
    void stateChanged();
    void recognizedTextChanged();
private:
    bool m_listening=false,m_speaking=false;
    QString m_locale="fa-IR",m_status="Ready",m_recognized;
};
