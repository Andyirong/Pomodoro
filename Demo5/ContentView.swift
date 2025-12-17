//
//  ContentView.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

struct ContentView: View {
    @State private var minutes: Int = 25
    @State private var seconds: Int = 0
    @State private var isActive: Bool = false
    @State private var progress: Double = 1.0
    @State private var timer: Timer?
    @State private var initialMinutes: Int = 25  // 记录初始选择的分钟数
    @State private var selectedThemeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType = .work
    @State private var showingTimePicker = false
    @State private var stopButtonProgress: CGFloat = 1.0  // 停止按钮的进度
    @State private var stopButtonTimer: Timer?  // 停止按钮的长按计时器

    var body: some View {
        ZStack {
            // 临时背景色
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.97), Color(red: 1.0, green: 0.9, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // 标题
                Text("番茄闹钟")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.4))
                    .padding(.top, 50)

                Spacer()

                // 倒计时显示区域
                ZStack {
                    Circle()
                        .stroke(getCurrentThemeColor().opacity(0.3), lineWidth: 12)
                        .frame(width: 250, height: 250)
                        .animation(.easeInOut(duration: 0.5), value: selectedThemeType)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [getCurrentThemeColor(), getCurrentThemeColor().opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: selectedThemeType)

                    VStack(spacing: 10) {
                        Text(displayTime)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(getContrastTextColor(backgroundColor: getCurrentThemeColor()))
                            .animation(.easeInOut(duration: 0.5), value: selectedThemeType)

                        Text(isActive ? "专注中..." : "准备好开始了吗？")
                            .font(.headline)
                            .foregroundColor(getContrastTextColor(backgroundColor: getCurrentThemeColor()).opacity(0.8))
                            .animation(.easeInOut(duration: 0.5), value: selectedThemeType)
                    }
                }
                .scaleEffect(isActive ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isActive)

                Spacer()

                // 控制按钮区域
                HStack(spacing: 20) {
                    // 重置按钮（计时器运行时禁用）
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(isActive ? Color.textSecondary : getContrastTextColor(backgroundColor: getCurrentThemeColor()))
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isActive ? Color.secondaryButton : getCurrentThemeColor().opacity(0.7))
                    )
                    .disabled(isActive)
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)

                    // 开始/暂停按钮
                    ZStack {
                        // 背景圆环
                        Circle()
                            .stroke(getCurrentThemeColor().opacity(0.2), lineWidth: 4)
                            .frame(width: 70, height: 70)

                        // 进度圆环
                        if isActive {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    getCurrentThemeColor(),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1), value: progress)
                        }

                        Button(action: toggleTimer) {
                            Image(systemName: isActive ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .frame(width: 62, height: 62)
                        .background(
                            Circle()
                                .fill(getCurrentThemeColor())
                        )
                    }
                    .shadow(color: getCurrentThemeColor().opacity(0.3), radius: 8, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)

                    // 停止按钮（长按3秒）
                    ZStack {
                        Circle()
                            .stroke(getCurrentThemeColor(), lineWidth: 4)
                            .opacity(0.3)

                        Circle()
                            .trim(from: stopButtonProgress, to: 1.0)
                            .stroke(
                                getCurrentThemeColor(),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(90))
                            .animation(.linear(duration: 0.1), value: stopButtonProgress)

                        Button(action: {}) {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(getCurrentThemeColor().opacity(0.8))
                        )
                        .scaleEffect(stopButtonProgress < 1.0 ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: stopButtonProgress)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if isActive && stopButtonTimer == nil {
                                        startStopButtonHold()
                                    }
                                }
                                .onEnded { _ in
                                    if stopButtonTimer != nil {
                                        cancelStopButtonHold()
                                    }
                                }
                        )
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)
                }

                Spacer()

                // 快速选择按钮
                QuickSelectButton(
                    minutes: $minutes,
                    onTap: {
                        showingTimePicker = true
                    },
                    timeType: $selectedThemeType,
                    isActive: isActive
                )
                .padding(.horizontal, 8)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .overlay(
            // 底部弹窗
            TimePickerModal(
                isPresented: $showingTimePicker,
                selectedTime: $minutes,
                selectedThemeType: $selectedThemeType,
                isActive: isActive
            )
        )
        .onDisappear {
            // 清理所有计时器
            timer?.invalidate()
            stopButtonTimer?.invalidate()
        }
        .onChange(of: minutes) { _, newValue in
            // 当选择新时间时，重置秒数和进度
            if !isActive {
                seconds = 0
                updateProgressForTime(newValue)
            }
        }
    }

    private var displayTime: String {
        let mins = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secs = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(mins):\(secs)"
    }

    // 获取当前选中的主题颜色
    private func getCurrentThemeColor() -> Color {
        switch selectedThemeType {
        case .work:
            return Color.themeWorkPink
        case .shortBreak:
            return Color.themeBreakMint
        case .longBreak:
            return Color.themeLongBreakPurple
        case .focus45, .focus60:
            return Color.themeFocusDeepPink
        case .break10, .break20:
            return Color.themeBreakLightMint
        case .custom:
            return Color.themeCustomPurple
        }
    }

    // 根据背景色获取对比色（黑色或白色）
    private func getContrastTextColor(backgroundColor: Color) -> Color {
        // 简化的对比度计算，基于颜色的亮度
        switch selectedThemeType {
        case .work, .longBreak, .focus45, .focus60, .custom:
            // 粉色、深粉色和紫色背景，使用白色文字
            return .white
        case .shortBreak, .break10, .break20:
            // 薄荷绿和浅薄荷绿背景，使用深色文字以保证可读性
            return Color(red: 0.2, green: 0.4, blue: 0.3)
        }
    }

    private func toggleTimer() {
        if !isActive {
            startTimer()
        } else {
            pauseTimer()
        }
    }

    private func startTimer() {
        isActive = true
        initialMinutes = minutes  // 记录开始时的分钟数
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimer()
        }
    }

    private func pauseTimer() {
        isActive = false
        timer?.invalidate()
    }

    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        // 停止时重置秒数，但保持当前选择的时间
        seconds = 0
        // 设置进度为满格
        progress = 1.0
    }

    private func resetTimer() {
        timer?.invalidate()
        stopButtonTimer?.invalidate()
        stopButtonTimer = nil
        isActive = false
        minutes = 25
        seconds = 0
        progress = 1.0
        initialMinutes = 25  // 重置初始时间
        selectedThemeType = .work  // 重置为默认主题
        stopButtonProgress = 1.0  // 重置停止按钮进度
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

    private func updateProgress() {
        let totalSeconds = minutes * 60 + seconds
        let initialTotal = initialMinutes * 60 // 使用实际选择的初始时间
        progress = Double(totalSeconds) / Double(initialTotal)
    }

    private func updateProgressForTime(_ newMinutes: Int) {
        // 根据选择的时间更新进度条（用于选择时间后）
        initialMinutes = newMinutes
        progress = 1.0  // 重置为满格
    }

    private func completeTimer() {
        timer?.invalidate()
        isActive = false
        print("🔔 计时完成！")
        resetTimer()
    }

    // MARK: - 停止按钮长按处理
    private func startStopButtonHold() {
        // 添加触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        stopButtonProgress = 1.0

        // 创建计时器，每0.1秒更新一次进度
        stopButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let newProgress = stopButtonProgress - 0.1/3.0  // 3秒内从1.0减到0.0

            if newProgress <= 0 {
                stopButtonProgress = 0
                stopButtonTimer?.invalidate()
                stopButtonTimer = nil

                // 长按完成，停止计时器
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    stopTimer()
                    stopButtonProgress = 1.0
                }

                // 添加完成触觉反馈
                let completionFeedback = UINotificationFeedbackGenerator()
                completionFeedback.notificationOccurred(.success)
            } else {
                stopButtonProgress = newProgress
            }
        }
    }

    private func cancelStopButtonHold() {
        stopButtonTimer?.invalidate()
        stopButtonTimer = nil

        // 松手时回弹动画
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            stopButtonProgress = 1.0
        }
    }
}

#Preview {
    ContentView()
}
