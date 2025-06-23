// DbusBridge.h

#ifndef DBUSBRIDGE_H
#define DBUSBRIDGE_H

#include <QObject>
#include <QDBusInterface>

class DbusBridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    explicit DbusBridge(QObject *parent = nullptr);

    QString status() const;

public slots:
    void refreshStatus();
    void sendToast();
    void setTimeout(int seconds);
    void disconnectByIndex(int index);

signals:
    void statusChanged(const QString &status);

private:
    QDBusInterface m_iface;
    QString m_status;
};

#endif // DBUSBRIDGE_H
