#pragma once
#include <QObject>
#include <QString>
#include <QTimer>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QNativeInterface>
#endif

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

    Q_INVOKABLE void startListening(){
#ifdef Q_OS_ANDROID
        m_listening=true; m_status="Listening — "+m_locale; emit stateChanged();
        auto context=QNativeInterface::QAndroidApplication::context();
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","startListening",
                                            "(Landroid/content/Context;Ljava/lang/String;)V",
                                            context,QJniObject::fromString(m_locale).object());
#else
        m_status="Android voice unavailable";emit stateChanged();
#endif
    }

    Q_INVOKABLE void stopListening(){
#ifdef Q_OS_ANDROID
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","stopListening","()V");
#endif
        m_listening=false;m_status="Ready";emit stateChanged();
    }

    Q_INVOKABLE void speak(const QString &text){
        if(text.trimmed().isEmpty())return;
#ifdef Q_OS_ANDROID
        m_speaking=true;m_status="Speaking — "+m_locale;emit stateChanged();
        auto context=QNativeInterface::QAndroidApplication::context();
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","speak",
                                            "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V",
                                            context,QJniObject::fromString(text).object(),
                                            QJniObject::fromString(m_locale).object());
#else
        m_speaking=true;m_status="TTS unavailable";emit stateChanged();
#endif
        QTimer::singleShot(1500,this,[this](){m_speaking=false;m_status="Ready";emit stateChanged();});
    }

    Q_INVOKABLE void acceptRecognition(const QString &text){
        m_recognized=text.trimmed();m_listening=false;
        m_status=m_recognized.startsWith("ERROR:") ? m_recognized :
                 (m_recognized.isEmpty()?"No speech recognized":"Speech recognized");
        emit recognizedTextChanged();emit stateChanged();
    }

signals:
    void stateChanged();
    void recognizedTextChanged();
private:
    bool m_listening=false,m_speaking=false;
    QString m_locale="fa-IR",m_status="Ready",m_recognized;
};
