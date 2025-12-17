//
//  PomodoroTimerViewModel.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SwiftUI
import Combine

/// Pomodoro计时器ViewModel - 统一计时器逻辑，分离业务逻辑
class PomodoroTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMinutes: Int = 25
    @Published var timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType = .work
    @Published var showingTimePicker: Bool = false
    @Published var stopButtonProgress: CGFloat = 1.0

    // MARK: - Timer Management
    private let timerManager = TimerManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Services
    private let databaseService: DatabaseServiceProtocol
    private let notificationService: NotificationServiceProtocol

    // MARK: - Computed Properties
    var displayTime: String {
        timerManager.displayTime
    }

    var progress: Double {
        timerManager.progress
    }

    var isActive: Bool {
        timerManager.isRunning
    }

    var canStart: Bool {
        timerManager.canStart
    }

    var canPause: Bool {
        timerManager.canPause
    }

    var canStop: Bool {
        timerManager.canStop
    }

    var stateText: String {
        switch timerManager.state {
        case .idle:
            return "准备好开始了吗？"
        case .running:
            return "专注中..."
        case .paused:
            return "已暂停"
        case .completed:
            return "完成！"
        }
    }

    // MARK: - Initialization
    init(databaseService: DatabaseServiceProtocol = DefaultDatabaseService(),
         notificationService: NotificationServiceProtocol = DefaultNotificationService()) {
        self.databaseService = databaseService
        self.notificationService = notificationService

        setupBindings()
        loadUserSettings()
    }

    // MARK: - Public Methods

    /// 开始/暂停计时器
    func toggleTimer() {
        if timerManager.isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    /// 开始计时器
    func startTimer() {
        let totalSeconds = selectedMinutes * 60

        // 保存当前设置到数据库
        Task {
            do {
                try await databaseService.saveTimerSetting(
                    minutes: selectedMinutes,
                    timeType: timeType.rawValue
                )
            } catch {
                print("保存计时器设置失败: \(error)")
            }
        }

        timerManager.start(seconds: totalSeconds)

        // 开始触觉反馈
        notificationService.provideImpactFeedback(.medium)
    }

    /// 暂停计时器
    func pauseTimer() {
        timerManager.pause()
        notificationService.provideImpactFeedback(.light)
    }

    /// 恢复计时器
    func resumeTimer() {
        timerManager.resume()
        notificationService.provideImpactFeedback(.light)
    }

    /// 停止计时器（重置）
    func stopTimer() {
        timerManager.stop()
        resetStopButton()
        notificationService.provideImpactFeedback(.medium)
    }

    /// 重置计时器到默认状态
    func resetToDefault() {
        timerManager.stop()
        selectedMinutes = 25
        timeType = .work
        resetStopButton()
    }

    /// 选择时间
    /// - Parameters:
    ///   - minutes: 选择的时间（分钟）
    ///   - type: 时间类型
    func selectTime(minutes: Int, type: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) {
        guard !timerManager.isRunning else { return }

        selectedMinutes = minutes
        timeType = type
        timerManager.resetTo(seconds: minutes * 60)
    }

    /// 开始停止按钮长按
    func startStopButtonHold() {
        guard timerManager.isRunning else { return }

        notificationService.provideImpactFeedback(.medium)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let newProgress = stopButtonProgress - 0.1/3.0

            if newProgress <= 0 {
                timer.invalidate()

                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    stopTimer()
                    resetStopButton()
                }

                notificationService.provideNotificationFeedback(.success)
            } else {
                stopButtonProgress = newProgress
            }
        }
    }

    /// 取消停止按钮长按
    func cancelStopButtonHold() {
        resetStopButton()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 监听计时器完成事件
        NotificationCenter.default
            .publisher(for: .timerManagerCompleted)
            .sink { [weak self] notification in
                self?.handleTimerCompletion(notification)
            }
            .store(in: &cancellables)

        // 监听时间选择变化
        $selectedMinutes
            .sink { [weak self] newMinutes in
                guard let self = self else { return }
                if !self.timerManager.isRunning {
                    self.timerManager.resetTo(seconds: newMinutes * 60)
                }
            }
            .store(in: &cancellables)
    }

    private func loadUserSettings() {
        Task {
            do {
                let settings = try await databaseService.getDefaultTimerSettings()
                await MainActor.run {
                    selectedMinutes = settings.minutes
                    if let savedType = ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType(rawValue: settings.timeType) {
                        timeType = savedType
                    }
                }
            } catch {
                print("加载用户设置失败: \(error)")
                // 使用默认值
                selectedMinutes = 25
                timeType = .work
            }
        }
    }

    private func handleTimerCompletion(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let totalTime = userInfo["totalTime"] as? Int else { return }

        Task {
            do {
                let minutes = totalTime / 60
                try await databaseService.saveCompletedTimer(
                    minutes: minutes,
                    timeType: timeType.rawValue,
                    completedAt: Date()
                )

                // 播放完成通知
                await notificationService.playCompletionSound()
                notificationService.provideNotificationFeedback(.success)

            } catch {
                print("保存完成的计时器记录失败: \(error)")
            }
        }
    }

    private func resetStopButton() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            stopButtonProgress = 1.0
        }
    }
}

// MARK: - Service Protocols
protocol DatabaseServiceProtocol {
    func saveTimerSetting(minutes: Int, timeType: String) async throws
    func getDefaultTimerSettings() async throws -> (minutes: Int, timeType: String)
    func saveCompletedTimer(minutes: Int, timeType: String, completedAt: Date) async throws
}

protocol NotificationServiceProtocol {
    func provideImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func provideNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func playCompletionSound() async
}

// MARK: - Default Service Implementations
class DefaultDatabaseService: DatabaseServiceProtocol {
    func saveTimerSetting(minutes: Int, timeType: String) async throws {
        // 实现数据库保存逻辑
        DatabaseManager.shared.setUserSetting(key: "last_selected_minutes", value: "\(minutes)")
        DatabaseManager.shared.setUserSetting(key: "last_selected_type", value: timeType)
    }

    func getDefaultTimerSettings() async throws -> (minutes: Int, timeType: String) {
        let minutes = DatabaseManager.shared.getUserSetting(key: "default_minutes", defaultValue: 25)
        let timeType = DatabaseManager.shared.getUserSetting(key: "default_time_type", defaultValue: "work")
        return (minutes: Int(minutes) ?? 25, timeType: timeType)
    }

    func saveCompletedTimer(minutes: Int, timeType: String, completedAt: Date) async throws {
        // 保存完成的计时器记录到数据库
        let timerDAO = try TimerDAO()
        let settings = TimerSettings(minutes: minutes, seconds: 0, note: "Completed Pomodoro")
        try timerDAO.saveOrUpdateTimerSettings(settings)

        // 更新统计数据
        let statsDAO = try StatsDAO()
        let todayStats = statsDAO.getTodayStats()
        try statsDAO.saveDailyStats(
            date: completedAt,
            totalMinutes: todayStats.totalMinutes + minutes,
            completedTomatoes: todayStats.completedTomatoes + 1,
            tasksDone: todayStats.tasksDone
        )
    }
}

class DefaultNotificationService: NotificationServiceProtocol {
    func provideImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }

    func provideNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }

    func playCompletionSound() async {
        // 播放系统提示音
        await withCheckedContinuation { continuation in
            AudioServicesPlaySystemSound(1005) // 系统提示音
            continuation.resume()
        }
    }
}