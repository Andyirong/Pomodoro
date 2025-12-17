//
//  TimerViewModel.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 25
    @Published var seconds: Int = 0
    @Published var initialMinutes: Int = 25
    @Published var initialSeconds: Int = 0
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var progress: Double = 1.0
    @Published var recentSettings: [TimerSettings] = []
    @Published var currentNote: String = ""

    private var timer: Timer?
    private var timerDAO = TimerDAO()
    private var statsDAO = StatsDAO()
    private let totalSecondsSubject = CurrentValueSubject<Int, Never>(0)

    init() {
        loadRecentSettings()
        loadUserSettings()
    }

    // MARK: - 计时器控制

    func start() {
        if !isActive {
            initialMinutes = minutes
            initialSeconds = seconds
            isActive = true
            isPaused = false

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        }
    }

    func pause() {
        if isActive && !isPaused {
            isPaused = true
            timer?.invalidate()
        }
    }

    func resume() {
        if isPaused {
            isPaused = false
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        }
    }

    func stop(longPress: Bool = false) {
        if longPress {
            // 长按停止功能
            timer?.invalidate()
            isActive = false
            isPaused = false
            minutes = initialMinutes
            seconds = initialSeconds
            progress = 1.0
        }
    }

    func reset() {
        timer?.invalidate()
        isActive = false
        isPaused = false
        minutes = initialMinutes
        seconds = initialSeconds
        progress = 1.0
    }

    private func updateTimer() {
        guard seconds > 0 || minutes > 0 else {
            // 计时结束
            completeTimer()
            return
        }

        if seconds > 0 {
            seconds -= 1
        } else {
            seconds = 59
            minutes -= 1
        }

        updateProgress()
    }

    private func completeTimer() {
        timer?.invalidate()
        isActive = false
        isPaused = false

        // 保存到历史记录
        let settings = TimerSettings(minutes: initialMinutes, seconds: initialSeconds, note: currentNote)
        timerDAO.saveOrUpdateTimerSettings(settings)

        // 更新统计数据
        let todayStats = statsDAO.getTodayStats()
        statsDAO.saveDailyStats(
            date: Date(),
            totalMinutes: todayStats.totalMinutes + initialMinutes,
            completedTomatoes: todayStats.completedTomatoes + 1,
            tasksDone: todayStats.tasksDone
        )

        // 触发通知
        NotificationCenter.default.post(name: .timerCompleted, object: nil)

        // 重置计时器
        reset()
    }

    // MARK: - 时间调整

    func adjustMinutes(_ delta: Int) {
        let newMinutes = max(0, minutes + delta)
        if newMinutes <= 99 && !isActive {
            minutes = newMinutes
            initialMinutes = newMinutes
            updateProgress()
        }
    }

    func adjustSeconds(_ delta: Int) {
        let totalSeconds = minutes * 60 + seconds + delta
        if totalSeconds >= 0 && totalSeconds <= 5999 && !isActive { // 最多99分59秒
            minutes = totalSeconds / 60
            seconds = totalSeconds % 60
            initialMinutes = minutes
            initialSeconds = seconds
            updateProgress()
        }
    }

    func setQuickTime(_ mins: Int) {
        if !isActive {
            minutes = mins
            seconds = 0
            initialMinutes = mins
            initialSeconds = 0
            updateProgress()
        }
    }

    // MARK: - 进度计算

    private func updateProgress() {
        let currentTotal = minutes * 60 + seconds
        let initialTotal = initialMinutes * 60 + initialSeconds
        progress = initialTotal > 0 ? Double(currentTotal) / Double(initialTotal) : 1.0
    }

    // MARK: - 数据管理

    private func loadRecentSettings() {
        recentSettings = timerDAO.getRecentTimerSettings(limit: 10)
    }

    private func loadUserSettings() {
        // 从数据库加载用户设置
        let defaultMinutes = getUserSetting(key: "default_minutes", defaultValue: 25)
        let defaultSeconds = getUserSetting(key: "default_seconds", defaultValue: 0)

        minutes = defaultMinutes
        seconds = defaultSeconds
        initialMinutes = defaultMinutes
        initialSeconds = defaultSeconds
    }

    private func getUserSetting(key: String, defaultValue: Int) -> Int {
        // 这里应该从数据库读取，暂时返回默认值
        return defaultValue
    }

    func saveCurrentSetting() {
        let settings = TimerSettings(minutes: initialMinutes, seconds: initialSeconds, note: currentNote)
        timerDAO.saveOrUpdateTimerSettings(settings)
        loadRecentSettings()
    }

    func loadSetting(_ settings: TimerSettings) {
        if !isActive {
            minutes = settings.minutes
            seconds = settings.seconds
            initialMinutes = settings.minutes
            initialSeconds = settings.seconds
            currentNote = settings.note
            updateProgress()
        }
    }

    // MARK: - 辅助属性

    var displayTime: String {
        let mins = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secs = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(mins):\(secs)"
    }

    var remainingSeconds: Int {
        return minutes * 60 + seconds
    }

    var totalSeconds: Int {
        return initialMinutes * 60 + initialSeconds
    }

    var canStart: Bool {
        return !isActive && (minutes > 0 || seconds > 0)
    }

    var canPause: Bool {
        return isActive && !isPaused
    }

    var canResume: Bool {
        return isPaused
    }

    var canReset: Bool {
        return isActive || isPaused
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}