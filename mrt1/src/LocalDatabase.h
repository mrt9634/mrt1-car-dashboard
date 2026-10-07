#pragma once

#include <QObject>
#include <QStandardPaths>
#include <QDir>
#include <QSqlDatabase>
#include <QSqlQuery>

class LocalDatabase : public QObject
{
    Q_OBJECT
public:
    explicit LocalDatabase(QObject *parent = nullptr) : QObject(parent) {}

    bool initialize()
    {
        const QString dir = QStandardPaths::writableLocation(
            QStandardPaths::AppDataLocation);
        QDir().mkpath(dir);

        if (QSqlDatabase::contains("mrt1"))
            m_db = QSqlDatabase::database("mrt1");
        else {
            m_db = QSqlDatabase::addDatabase("QSQLITE", "mrt1");
            m_db.setDatabaseName(dir + "/mrt1.db");
        }

        if (!m_db.open())
            return false;

        QSqlQuery q(m_db);
        q.exec("CREATE TABLE IF NOT EXISTS settings "
               "(key TEXT PRIMARY KEY, value TEXT)");
        q.exec("CREATE TABLE IF NOT EXISTS diagnostics "
               "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "timestamp INTEGER, code TEXT, message TEXT)");

        return true;
    }

private:
    QSqlDatabase m_db;
};
