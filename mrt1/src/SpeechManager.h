#pragma once
#include <QObject>
#include <QString>
#ifdef Q_OS_ANDROID
#include <QJniObject>
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

    void setLocale(const QString &v){
        const QString nv = v.trimmed().isEmpty() ? QStringLiteral("fa-IR") : v.trimmed();
        if (m_locale == nv) return;
        m_locale = nv;
        emit stateChanged();
    }

    Q_INVOKABLE void startListening(){
#ifdef Q_OS_ANDROID
        if (m_speaking) {
            m_status = QStringLiteral("Cannot listen while speaking");
            emit stateChanged();
            return;
        }
        const bool granted = QJniObject::callStaticMethod<jboolean>(
            "com/mrt/jarvis/SpeechBridge","hasRecordPermission","()Z");
        if(!granted){
            QJniObject::callStaticMethod<void>(
                "com/mrt/jarvis/SpeechBridge","requestRecordPermission","()V");
            m_status = QStringLiteral("Microphone permission required — tap VOICE again");
            emit stateChanged();
            return;
        }
        // Clear previous result before new attempt
        if (!m_recognized.isEmpty()) {
            m_recognized.clear();
            emit recognizedTextChanged();
        }
        m_listening = true;
        m_status = QStringLiteral("Listening — ") + m_locale;
        emit stateChanged();
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","startListening",
                                            "(Ljava/lang/String;)V",
                                            QJniObject::fromString(m_locale).object());
#else
        m_listening = false;
        m_status = QStringLiteral("Android voice unavailable");
        emit stateChanged();
#endif
    }

    Q_INVOKABLE void stopListening(){
#ifdef Q_OS_ANDROID
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","stopListening","()V");
#endif
        m_listening = false;
        m_status = QStringLiteral("Ready");
        emit stateChanged();
    }

    Q_INVOKABLE void speak(const QString &text){
        if(text.trimmed().isEmpty()) return;
#ifdef Q_OS_ANDROID
        if (m_speaking) {
            // Already speaking — let the new call queue
            m_status = QStringLiteral("Speaking — ") + m_locale;
            emit stateChanged();
        } else {
            m_speaking = true;
            m_status = QStringLiteral("Speaking — ") + m_locale;
            emit stateChanged();
        }
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/SpeechBridge","speak",
                                            "(Ljava/lang/String;Ljava/lang/String;)V",
                                            QJniObject::fromString(text).object(),
                                            QJniObject::fromString(m_locale).object());
#else
        // No TTS on desktop — reset immediately so nothing locks up
        m_speaking = false;
        m_status = QStringLiteral("TTS unavailable on this platform");
        emit stateChanged();
#endif
    }

    Q_INVOKABLE void acceptTtsDone(){
        m_speaking = false;
        m_status = QStringLiteral("Ready");
        emit stateChanged();
    }

    Q_INVOKABLE void acceptRecognition(const QString &text){
        m_recognized = text.trimmed();
        m_listening = false;

        if (m_recognized.startsWith(QStringLiteral("ERROR:"))) {
            m_status = m_recognized;
        } else if (m_recognized.isEmpty()) {
            m_status = QStringLiteral("No speech recognized");
        } else {
            m_status = QStringLiteral("Speech recognized");
        }
        emit recognizedTextChanged();
        emit stateChanged();
    }

    Q_INVOKABLE void clearRecognizedText(){
        if (m_recognized.isEmpty()) return;
        m_recognized.clear();
        emit recognizedTextChanged();
    }

signals:
    void stateChanged();
    void recognizedTextChanged();

private:
    bool m_listening=false;
    bool m_speaking=false;
    QString m_locale=QStringLiteral("fa-IR");
    QString m_status=QStringLiteral("Ready");
    QString m_recognized;
};
