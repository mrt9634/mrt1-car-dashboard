#pragma once
#include <QObject>
#include <QString>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QNativeInterface>
#endif

class PhoneManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool permissionGranted READ permissionGranted NOTIFY stateChanged)
    Q_PROPERTY(bool inCall READ inCall NOTIFY stateChanged)
    Q_PROPERTY(QString stateText READ stateText NOTIFY stateChanged)
    Q_PROPERTY(QString number READ number NOTIFY stateChanged)
    Q_PROPERTY(QString status READ status NOTIFY stateChanged)
public:
    explicit PhoneManager(QObject *parent=nullptr):QObject(parent){}
    bool permissionGranted() const{return m_permission;}
    bool inCall() const{return m_inCall;}
    QString stateText() const{return m_stateText;}
    QString number() const{return m_number;}
    QString status() const{return m_status;}

    Q_INVOKABLE void refresh(){
#ifdef Q_OS_ANDROID
        auto context=QNativeInterface::QAndroidApplication::context();
        m_permission=QJniObject::callStaticMethod<jboolean>(
            "com/mrt/jarvis/PhoneBridge","hasPhonePermission",
            "(Landroid/content/Context;)Z",context);
        if(!m_permission){
            m_inCall=false; m_stateText="PERMISSION REQUIRED"; m_status="Phone permission is required for call-state access.";
        } else {
            jint state=QJniObject::callStaticMethod<jint>(
                "com/mrt/jarvis/PhoneBridge","getPhoneState",
                "(Landroid/content/Context;)I",context);
            m_inCall=(state==2);
            m_stateText=state==2?"IN CALL":(state==1?"RINGING":"IDLE");
            m_status="Native Android telephony status";
        }
#else
        m_permission=false; m_inCall=false; m_stateText="ANDROID ONLY"; m_status="Phone integration is available on Android.";
#endif
        emit stateChanged();
    }

    Q_INVOKABLE void requestPermission(){
#ifdef Q_OS_ANDROID
        QJniObject::callStaticMethod<void>("com/mrt/jarvis/PhoneBridge","requestPhonePermission","()V");
#endif
        m_status="Permission request sent — check Android permission dialog.";
        emit stateChanged();
    }
signals:
    void stateChanged();
private:
    bool m_permission=false;
    bool m_inCall=false;
    QString m_stateText="IDLE";
    QString m_number;
    QString m_status="Not checked";
};
