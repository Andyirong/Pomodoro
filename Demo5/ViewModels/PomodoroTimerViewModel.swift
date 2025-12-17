//
//  PomodoroTimerViewModel.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox

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
        databaseService.saveTimerSetting(
            minutes: selectedMinutes,
            timeType: timeType.rawValue
        ) { error in
            if let error = error {
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

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            let newProgress = self.stopButtonProgress - 0.1/3.0

            if newProgress <= 0 {
                timer.invalidate()

                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.stopTimer()
                    self.resetStopButton()
                }

                self.notificationService.provideNotificationFeedback(.success)
            } else {
                self.stopButtonProgress = newProgress
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
        databaseService.getDefaultTimerSettings { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let settings):
                    self.selectedMinutes = settings.minutes
                    if let savedType = ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType(rawValue: settings.timeType) {
                        self.timeType = savedType
                    }
                case .failure(let error):
                    print("加载用户设置失败: \(error)")
                    // 使用默认值
                    self.selectedMinutes = 25
                    self.timeType = .work
                }
            }
        }
    }

    private func handleTimerCompletion(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let totalTime = userInfo["totalTime"] as? Int else { return }

        let minutes = totalTime / 60
        databaseService.saveCompletedTimer(
            minutes: minutes,
            timeType: timeType.rawValue,
            completedAt: Date()
        ) { [weak self] error in
            if let error = error {
                print("保存完成的计时器记录失败: \(error)")
                return
            }

            // 播放完成通知
            self?.notificationService.playCompletionSound {
                self?.notificationService.provideNotificationFeedback(.success)
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
    func saveTimerSetting(minutes: Int, timeType: String, completion: @escaping (Error?) -> Void)
    func getDefaultTimerSettings(completion: @escaping (Result<(minutes: Int, timeType: String), Error>) -> Void)
    func saveCompletedTimer(minutes: Int, timeType: String, completedAt: Date, completion: @escaping (Error?) -> Void)
}

protocol NotificationServiceProtocol {
    func provideImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func provideNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func playCompletionSound(completion: @escaping () -> Void)
}

// MARK: - Default Service Implementations
class DefaultDatabaseService: DatabaseServiceProtocol {
    func saveTimerSetting(minutes: Int, timeType: String, completion: @escaping (Error?) -> Void) {
        // 暂时使用UserDefaults保存，避免SQLite依赖问题
        UserDefaults.standard.set(minutes, forKey: "last_selected_minutes")
        UserDefaults.standard.set(timeType, forKey: "last_selected_type")
        completion(nil)
    }

    func getDefaultTimerSettings(completion: @escaping (Result<(minutes: Int, timeType: String), Error>) -> Void) {
        let minutes = UserDefaults.standard.integer(forKey: "default_minutes")
        let timeType = UserDefaults.standard.string(forKey: "default_time_type") ?? "work"
        let result = (minutes: minutes > 0 ? minutes : 25, timeType: timeType)
        completion(.success(result))
    }

    func saveCompletedTimer(minutes: Int, timeType: String, completedAt: Date, completion: @escaping (Error?) -> Void) {
        // 暂时使用UserDefaults保存统计信息
        let completedCount = UserDefaults.standard.integer(forKey: "completed_tomatoes") + 1
        UserDefaults.standard.set(completedCount, forKey: "completed_tomatoes")

        let totalMinutes = UserDefaults.standard.integer(forKey: "total_minutes") + minutes
        UserDefaults.standard.set(totalMinutes, forKey: "total_minutes")

        print("✅ 保存完成的计时器记录: \(minutes)分钟")
        completion(nil)
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

    func playCompletionSound(completion: @escaping () -> Void) {
        // 播放系统提示音
        AudioServicesPlaySystemSound(1005) // 系统提示音
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }
}