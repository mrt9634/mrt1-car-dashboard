#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSettings>
#include <QTimer>
#include <QPointer>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#endif

class OpenAIManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY stateChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY stateChanged)
    Q_PROPERTY(QString apiUrl READ apiUrl WRITE setApiUrl NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
    Q_PROPERTY(QString reply READ reply NOTIFY replyChanged)
public:
    explicit OpenAIManager(QObject *parent=nullptr):QObject(parent) {
        QSettings s;
        m_enabled = s.value("ai/enabled", true).toBool();
        m_model   = s.value("ai/model", "gpt-4o-mini").toString();
        m_url     = s.value("ai/url", "https://api.openai.com/v1/responses").toString();

#ifdef Q_OS_ANDROID
        QJniObject key = QJniObject::callStaticObjectMethod(
            "com/mrt/jarvis/SpeechBridge", "loadApiKey",
            "()Ljava/lang/String;");
        if (key.isValid()) m_key = key.toString();
#else
        m_key = s.value("ai/key").toString();
#endif

        if (m_key.isEmpty())
            m_status = QStringLiteral("API key missing — open JARVIS settings");
    }

    bool enabled() const {return m_enabled;}
    bool busy() const {return m_busy;}
    QString model() const {return m_model;}
    QString apiUrl() const {return m_url;}
    QString status() const {return m_status;}
    QString reply() const {return m_reply;}

    void setEnabled(bool v){
        if (m_enabled == v) return;
        m_enabled = v;
        QSettings().setValue("ai/enabled", v);
        emit stateChanged();
    }

    void setModel(const QString &v){
        const QString nv = v.trimmed();
        if (m_model == nv) return;
        m_model = nv;
        QSettings().setValue("ai/model", m_model);
        emit stateChanged();
    }

    void setApiUrl(const QString &v){
        const QString nv = v.trimmed();
        if (m_url == nv) return;
        m_url = nv;
        QSettings().setValue("ai/url", m_url);
        emit stateChanged();
    }

    Q_INVOKABLE void setApiKey(const QString &key){
        m_key = key.trimmed();
#ifdef Q_OS_ANDROID
        const bool ok = QJniObject::callStaticMethod<jboolean>(
            "com/mrt/jarvis/SpeechBridge", "saveApiKey",
            "(Ljava/lang/String;)Z",
            QJniObject::fromString(m_key).object());
        m_status = ok
            ? (m_key.isEmpty() ? QStringLiteral("API key missing")
                               : QStringLiteral("API key saved securely"))
            : QStringLiteral("Could not secure API key");
#else
        QSettings().setValue("ai/key", m_key);
        QSettings().sync();
        m_status = m_key.isEmpty()
            ? QStringLiteral("API key missing")
            : QStringLiteral("API key saved locally");
#endif
        emit stateChanged();
    }

    Q_INVOKABLE void clearApiKey(){
        m_key.clear();
#ifdef Q_OS_ANDROID
        QJniObject::callStaticMethod<void>(
            "com/mrt/jarvis/SpeechBridge", "clearApiKey", "()V");
#else
        QSettings().remove("ai/key");
        QSettings().sync();
#endif
        m_status = QStringLiteral("API key removed");
        emit stateChanged();
    }

    Q_INVOKABLE void ask(const QString &text){
        if (!m_enabled){
            m_status = QStringLiteral("AI disabled");
            emit stateChanged();
            return;
        }
        if (m_key.isEmpty()){
            m_status = QStringLiteral("API key missing — open JARVIS settings");
            emit stateChanged();
            return;
        }
        if (text.trimmed().isEmpty()) return;

        // Cancel any in-flight request
        if (m_currentReply && m_currentReply->isRunning()) {
            m_currentReply->abort();
        }

        QNetworkRequest req{QUrl(m_url)};
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        req.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
        req.setTransferTimeout(30000); // 30s timeout (Qt 6.7+)

        QJsonObject body{
            {"model", m_model},
            {"input", text},
            {"instructions",
             "You are JARVIS for MRT1, an automotive Android cockpit. "
             "Reply concisely in Persian unless the user asks for English. "
             "Never invent vehicle sensor values and never claim to have changed "
             "factory MCU/CAN settings unless a real verified operation succeeded."}
        };

        m_busy = true;
        m_status = QStringLiteral("Connecting to OpenAI...");
        emit stateChanged();

        QNetworkReply *reply = m_net.post(req, QJsonDocument(body).toJson(QJsonDocument::Compact));
        m_currentReply = reply;

        connect(reply, &QNetworkReply::finished, this, [this, reply](){
            const QByteArray data = reply->readAll();

            if (reply->error() != QNetworkReply::NoError) {
                if (reply->error() == QNetworkReply::OperationCanceledError) {
                    m_status = QStringLiteral("Request cancelled");
                } else {
                    m_status = QStringLiteral("OpenAI error: ") + reply->errorString();
                }
            } else {
                const auto doc = QJsonDocument::fromJson(data);

                // Try output_text first (Responses API)
                QString output = doc.object().value("output_text").toString().trimmed();

                // Fallback: parse output[].content[].text
                if (output.isEmpty()) {
                    const auto out = doc.object().value("output").toArray();
                    for (const auto &item : out) {
                        const auto content = item.toObject().value("content").toArray();
                        for (const auto &part : content) {
                            const QString t = part.toObject().value("text").toString();
                            if (!t.isEmpty()) {
                                if (!output.isEmpty()) output += "\n";
                                output += t;
                            }
                        }
                    }
                }

                // Fallback: chat-completions style
                if (output.isEmpty()) {
                    const auto choices = doc.object().value("choices").toArray();
                    if (!choices.isEmpty()) {
                        output = choices.first().toObject()
                                 .value("message").toObject()
                                 .value("content").toString().trimmed();
                    }
                }

                if (!output.isEmpty()) {
                    m_reply = output;
                    emit replyChanged();
                    m_status = QStringLiteral("OpenAI online");
                } else {
                    m_status = QStringLiteral("Invalid OpenAI response");
                }
            }

            m_busy = false;
            emit stateChanged();

            if (m_currentReply == reply) m_currentReply = nullptr;
            reply->deleteLater();
        });
    }

signals:
    void stateChanged();
    void replyChanged();

private:
    QNetworkAccessManager m_net;
    bool m_enabled = true;
    bool m_busy = false;
    QString m_model = QStringLiteral("gpt-4o-mini");
    QString m_url = QStringLiteral("https://api.openai.com/v1/responses");
    QString m_key;
    QString m_status = QStringLiteral("Not connected");
    QString m_reply;
    QPointer<QNetworkReply> m_currentReply;
};
