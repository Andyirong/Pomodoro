//
//  TimerManager.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import Combine

/// 计时器状态枚举
enum TimerState {
    case idle
    case running
    case paused
    case completed
}

/// 计时器管理器 - 解决内存泄漏和统一计时器逻辑
class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTime: Int = 0
    @Published var totalTime: Int = 0
    @Published var state: TimerState = .idle
    @Published var progress: Double = 1.0

    // MARK: - Private Properties
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    deinit {
        stopTimer()
        cancellables.removeAll()
    }

    // MARK: - Public Methods

    /// 开始计时器
    /// - Parameters:
    ///   - seconds: 总秒数
    ///   - tickInterval: 计时间隔，默认为1秒
    func start(seconds: Int, tickInterval: TimeInterval = 1.0) {
        guard state != .running else { return }

        stopTimer()

        totalTime = seconds
        currentTime = seconds
        state = .running

        // 使用 weak self 避免循环引用
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// 暂停计时器
    func pause() {
        guard state == .running else { return }

        state = .paused
        stopTimer()
    }

    /// 恢复计时器
    func resume() {
        guard state == .paused else { return }

        state = .running

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// 停止计时器
    func stop() {
        state = .idle
        currentTime = 0
        totalTime = 0
        progress = 1.0
        stopTimer()
    }

    /// 重置到指定时间
    /// - Parameter seconds: 重置的秒数
    func resetTo(seconds: Int) {
        guard state != .running else { return }

        totalTime = seconds
        currentTime = seconds
        state = .idle
        updateProgress()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 监听时间变化，更新进度
        $currentTime
            .combineLatest($totalTime)
            .sink { [weak self] current, total in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }

    private func tick() {
        guard currentTime > 0 else {
            completeTimer()
            return
        }

        currentTime -= 1
    }

    private func completeTimer() {
        state = .completed
        stopTimer()

        // 发送完成通知
        NotificationCenter.default.post(
            name: .timerManagerCompleted,
            object: self,
            userInfo: [
                "totalTime": totalTime,
                "completedAt": Date()
            ]
        )
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateProgress() {
        guard totalTime > 0 else {
            progress = 1.0
            return
        }
        progress = Double(currentTime) / Double(totalTime)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let timerManagerCompleted = Notification.Name("timerManagerCompleted")
}

// MARK: - Convenience Properties
extension TimerManager {
    /// 格式化的显示时间 (MM:SS)
    var displayTime: String {
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 是否可以开始
    var canStart: Bool {
        state == .idle && totalTime > 0
    }

    /// 是否可以暂停
    var canPause: Bool {
        state == .running
    }

    /// 是否可以恢复
    var canResume: Bool {
        state == .paused
    }

    /// 是否可以停止
    var canStop: Bool {
        state != .idle
    }

    /// 是否正在运行
    var isRunning: Bool {
        state == .running
    }

    /// 剩余分钟数
    var minutes: Int {
        currentTime / 60
    }

    /// 剩余秒数
    var seconds: Int {
        currentTime % 60
    }
}