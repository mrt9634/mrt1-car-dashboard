#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSettings>

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
        m_enabled=s.value("ai/enabled",true).toBool();
        m_model=s.value("ai/model","gpt-5-mini").toString();
        m_url=s.value("ai/url","https://api.openai.com/v1/chat/completions").toString();
        m_key=s.value("ai/key").toString();
    }
    bool enabled() const{return m_enabled;}
    bool busy() const{return m_busy;}
    QString model() const{return m_model;}
    QString apiUrl() const{return m_url;}
    QString status() const{return m_status;}
    QString reply() const{return m_reply;}

    void setEnabled(bool v){m_enabled=v;QSettings().setValue("ai/enabled",v);emit stateChanged();}
    void setModel(const QString &v){m_model=v.trimmed();QSettings().setValue("ai/model",m_model);emit stateChanged();}
    void setApiUrl(const QString &v){m_url=v.trimmed();QSettings().setValue("ai/url",m_url);emit stateChanged();}
    Q_INVOKABLE void setApiKey(const QString &key){m_key=key.trimmed();QSettings().setValue("ai/key",m_key);QSettings().sync();m_status=m_key.isEmpty()?"API key missing":"API key saved locally";emit stateChanged();}
    Q_INVOKABLE void clearApiKey(){m_key.clear();QSettings().remove("ai/key");QSettings().sync();m_status="API key removed";emit stateChanged();}

    Q_INVOKABLE void ask(const QString &text){
        if(!m_enabled){m_status="AI disabled";emit stateChanged();return;}
        if(m_key.isEmpty()){m_status="API key missing";emit stateChanged();return;}
        if(text.trimmed().isEmpty())return;

        QNetworkRequest req{QUrl(m_url)};
        req.setHeader(QNetworkRequest::ContentTypeHeader,"application/json");
        req.setRawHeader("Authorization",("Bearer "+m_key).toUtf8());

        QJsonArray messages;
        messages.append(QJsonObject{{"role","system"},{"content",
            "You are JARVIS for MRT1, an automotive Android cockpit. Reply concisely in Persian unless the user asks for English. Never invent vehicle sensor values and never claim to have changed factory MCU/CAN settings unless a real verified operation succeeded."}});
        messages.append(QJsonObject{{"role","user"},{"content",text}});

        QJsonObject body{{"model",m_model},{"messages",messages},{"temperature",0.2}};
        m_busy=true;m_status="Connecting to OpenAI...";emit stateChanged();

        auto *replyObj=m_net.post(req,QJsonDocument(body).toJson(QJsonDocument::Compact));
        connect(replyObj,&QNetworkReply::finished,this,[this,replyObj](){
            const QByteArray data=replyObj->readAll();
            if(replyObj->error()!=QNetworkReply::NoError){
                m_status="OpenAI error: "+replyObj->errorString();
            } else {
                const auto doc=QJsonDocument::fromJson(data);
                const auto choices=doc.object().value("choices").toArray();
                if(!choices.isEmpty()){
                    m_reply=choices.first().toObject().value("message").toObject().value("content").toString().trimmed();
                    emit replyChanged();
                    m_status="OpenAI online";
                } else m_status="Invalid OpenAI response";
            }
            m_busy=false;emit stateChanged();replyObj->deleteLater();
        });
    }
signals:
    void stateChanged();
    void replyChanged();
private:
    QNetworkAccessManager m_net;
    bool m_enabled=true,m_busy=false;
    QString m_model="gpt-5-mini";
    QString m_url="https://api.openai.com/v1/chat/completions";
    QString m_key,m_status="Not connected",m_reply;
};
