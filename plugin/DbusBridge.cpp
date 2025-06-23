#include "DbusBridge.h"
#include <QDBusReply>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QElapsedTimer>

DbusBridge::DbusBridge(QObject *parent)
    : QObject(parent),
      m_iface("org.dualsense.Monitor", "/org/dualsense/Monitor", "org.dualsense.Monitor", QDBusConnection::sessionBus())
{}

QString DbusBridge::status() const {
    return m_status;
}

void DbusBridge::refreshStatus() {
    static QElapsedTimer timer;
    if (timer.isValid() && timer.elapsed() < 1000) {
        return;  // Avoid redundant refreshes
    }
    timer.restart();

    QDBusPendingCall asyncCall = m_iface.asyncCall("GetStatus");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(asyncCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher]() {
        watcher->deleteLater();

        if (watcher->isError()) {
            qWarning() << "D-Bus async GetStatus failed:" << watcher->error().message();
            return;
        }

        const QString newStatus = watcher->reply().arguments().value(0).toString().trimmed();
        if (newStatus.isEmpty()) {
            qWarning() << "GetStatus returned empty.";
            return;
        }

        QJsonParseError parseError;
        QJsonDocument newDoc = QJsonDocument::fromJson(newStatus.toUtf8(), &parseError);

        if (parseError.error != QJsonParseError::NoError || !newDoc.isObject()) {
            qWarning() << "Invalid JSON from GetStatus:" << parseError.errorString();
            return;
        }

        QJsonDocument oldDoc = QJsonDocument::fromJson(m_status.toUtf8());
        if (!oldDoc.isNull() && oldDoc == newDoc) {
            return;  // No change
        }

        m_status = newStatus;
        qDebug() << "Status updated, emitting signal. Length:" << m_status.length();
        emit statusChanged(m_status);
    });
}

void DbusBridge::sendToast() {
    QDBusPendingCall asyncCall = m_iface.asyncCall("SendStatusToast");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(asyncCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher]() {
        if (watcher->isError()) {
            qWarning() << "SendStatusToast failed:" << watcher->error().message();
        }
        watcher->deleteLater();
    });
}

void DbusBridge::setTimeout(int seconds) {
    QDBusPendingCall asyncCall = m_iface.asyncCall("SetTimeout", seconds);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(asyncCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher, seconds]() {
        if (watcher->isError()) {
            qWarning() << "SetTimeout failed for" << seconds << "s:" << watcher->error().message();
        }
        watcher->deleteLater();
    });
}

void DbusBridge::disconnectByIndex(int index) {
    QDBusPendingCall asyncCall = m_iface.asyncCall("DisconnectByIndex", index);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(asyncCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher, index]() {
        if (watcher->isError()) {
            qWarning() << "Async DisconnectByIndex failed for index" << index << ":" << watcher->error().message();
        } else {
            qDebug() << "Controller at index" << index << "disconnected successfully.";
        }
        watcher->deleteLater();
    });
}
