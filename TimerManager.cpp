
#include "TimerManager.h"
#include "tracker.h"
#include <QTimer>

extern Tracker tracker; // global tracker

TimerManager::TimerManager(DatabaseHelper* dbHelper, QObject* parent)
    : QObject(parent), m_seconds(0), m_running(false), m_dbHelper(dbHelper)
{
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &TimerManager::onTimeout);
}

int TimerManager::seconds() const { return m_seconds; }
bool TimerManager::isRunning() const { return m_running; }

// void TimerManager::start() {
//     if (!m_running) {
//         m_running = true;
//         emit runningChanged();
//         m_timer.start();
//         tracker.start();
//     }
// }



void TimerManager::stop() {
    if (m_running) {
        m_timer.stop();
        m_aiTimer.stop();     // stop AI sync
        m_running = false;
        emit runningChanged();

        tracker.stop();

        if (m_dbHelper)
            m_dbHelper->saveTimerSeconds(m_currentUser, m_seconds);
    }
}


void TimerManager::start() {
    if (!m_running) {
        m_running = true;
        emit runningChanged();

        // ✅ Start main tracker timer
        m_timer.start();

        // ✅ Start AI sync timer if period is set
        if (m_aiSyncPeriod > 0) {
            m_aiTimer.setInterval(m_aiSyncPeriod * 60 * 1000); // minutes → ms
            m_aiTimer.start();
        }

        tracker.start();
    }
}

void TimerManager::setCurrentUser(const QString &userId) {
    m_currentUser = userId;
    tracker.setCurrentUser(userId);
    qDebug() << "Current user set to:" << m_currentUser;
}


// void TimerManager::stop() {
//     if (m_running) {
//         m_timer.stop();
//         m_running = false;
//         emit runningChanged();
//         tracker.stop();
//         if (m_dbHelper)
//             m_dbHelper->saveTimerSeconds(m_currentUser, m_seconds); // save on stop
//     }
// }

void TimerManager::reset() {
    m_seconds = 0;
    emit secondsChanged();
    if (m_dbHelper)
        m_dbHelper->saveTimerSeconds(m_currentUser, m_seconds);
}

void TimerManager::loadSavedTime() {
    if (m_dbHelper && !m_currentUser.isEmpty()) {
        m_seconds = m_dbHelper->loadTimerSeconds(m_currentUser);
        emit secondsChanged();
    }
}

void TimerManager::onTimeout() {
    ++m_seconds;
    emit secondsChanged();

    if (m_dbHelper && !m_currentUser.isEmpty()) {
        m_dbHelper->saveTimerSeconds(m_currentUser, m_seconds);
    }
}




    // 🔹 forward to tracker



// void TimerManager::onTimeout() {
//     ++m_seconds;
//     emit secondsChanged();

//     // Auto-save every second while running
//     if (m_dbHelper) {
//         m_dbHelper->saveTimerSeconds(m_seconds);
//     }
// }


