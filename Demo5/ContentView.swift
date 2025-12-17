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
    @State private var selectedThemeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType = .work

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
                    // 重置按钮
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(getContrastTextColor(backgroundColor: getCurrentThemeColor()))
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(getCurrentThemeColor().opacity(0.7))
                    )
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)

                    // 开始/暂停按钮
                    Button(action: toggleTimer) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(getCurrentThemeColor())
                    )
                    .shadow(color: getCurrentThemeColor().opacity(0.3), radius: 8, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)

                    // 停止按钮
                    Button(action: stopTimer) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(getCurrentThemeColor().opacity(0.8))
                    )
                    .animation(.easeInOut(duration: 0.3), value: selectedThemeType)
                }

                Spacer()

                // 美好快速选择按钮
                QuickTimePicker(selectedTime: $minutes, selectedThemeType: $selectedThemeType, isActive: isActive)
                    .onChange(of: minutes) { _, newValue in
                        // 当选择新时间时，重置秒数和进度
                        if !isActive {
                            seconds = 0
                            updateProgressForTime(newValue)
                        }
                    }
                    .padding(.horizontal, 8)

                Spacer()
            }
            .padding(.horizontal, 20)
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
        }
    }

    // 根据背景色获取对比色（黑色或白色）
    private func getContrastTextColor(backgroundColor: Color) -> Color {
        // 简化的对比度计算，基于颜色的亮度
        switch selectedThemeType {
        case .work, .longBreak:
            // 粉色和紫色背景，使用白色文字
            return .white
        case .shortBreak:
            // 薄荷绿背景，使用深色文字以保证可读性
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
        minutes = 25
        seconds = 0
        progress = 1.0
    }

    private func resetTimer() {
        timer?.invalidate()
        isActive = false
        minutes = 25
        seconds = 0
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

    private func updateProgress() {
        let totalSeconds = minutes * 60 + seconds
        let initialTotal = 25 * 60 // 假设初始为25分钟
        progress = Double(totalSeconds) / Double(initialTotal)
    }

    private func updateProgressForTime(_ newMinutes: Int) {
        // 根据选择的时间更新进度条
        let totalSeconds = newMinutes * 60
        let initialTotal = 25 * 60 // 基准时间为25分钟
        progress = Double(totalSeconds) / Double(initialTotal)
    }

    private func completeTimer() {
        timer?.invalidate()
        isActive = false
        print("🔔 计时完成！")
        resetTimer()
    }
}

#Preview {
    ContentView()
}
