//
//  PomodoroContentView.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI
import AVFoundation

/// 重构后的Pomodoro主视图 - 专注于UI展示，业务逻辑分离到ViewModel
struct PomodoroContentView: View {
    // MARK: - StateObject
    @StateObject private var viewModel = PomodoroTimerViewModel()

    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景渐变
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // 标题
                titleSection

                Spacer()

                // 倒计时显示区域
                timerDisplaySection

                Spacer()

                // 控制按钮区域
                controlButtonsSection

                Spacer()

                // 快速选择按钮
                quickSelectSection

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .overlay(
            // 底部弹窗
            timePickerModal
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // 应用进入后台时的处理
            if viewModel.isActive {
                // 可以在这里添加后台计时逻辑
            }
        }
    }

    // MARK: - View Components

    private var backgroundGradient: some View {
        LinearGradient(
            colors: AppConfig.Colors.backgroundGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var titleSection: some View {
        Text(AppConfig.UI.appTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(AppConfig.Colors.titleColor)
            .padding(.top, 50)
    }

    private var timerDisplaySection: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(currentThemeColor.opacity(0.3), lineWidth: 12)
                .frame(width: AppConfig.UI.timerCircleSize, height: AppConfig.UI.timerCircleSize)
                .animation(.easeInOut(duration: 0.5), value: viewModel.timeType)

            // 进度圆环
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    LinearGradient(
                        colors: [currentThemeColor, currentThemeColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: AppConfig.UI.timerCircleSize, height: AppConfig.UI.timerCircleSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: viewModel.timeType)

            // 时间和状态显示
            VStack(spacing: 10) {
                Text(viewModel.displayTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(contrastTextColor)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.timeType)

                Text(viewModel.stateText)
                    .font(.headline)
                    .foregroundColor(contrastTextColor.opacity(0.8))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.timeType)
            }
        }
        .scaleEffect(viewModel.isActive ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.isActive)
    }

    private var controlButtonsSection: some View {
        HStack(spacing: 20) {
            // 重置按钮
            resetButton

            // 开始/暂停按钮
            playPauseButton

            // 停止按钮（长按）
            stopButton
        }
    }

    private var resetButton: some View {
        Button(action: viewModel.resetToDefault) {
            Image(systemName: "arrow.clockwise")
                .font(.title2)
                .foregroundColor(viewModel.isActive ? Color.textSecondary : contrastTextColor)
        }
        .frame(width: 50, height: 50)
        .background(
            Circle()
                .fill(viewModel.isActive ? Color.secondaryButton : currentThemeColor.opacity(0.7))
        )
        .disabled(viewModel.isActive)
        .animation(.easeInOut(duration: 0.3), value: viewModel.timeType)
    }

    private var playPauseButton: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(currentThemeColor.opacity(0.2), lineWidth: 4)
                .frame(width: 70, height: 70)

            // 进度圆环
            if viewModel.isActive {
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        currentThemeColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.progress)
            }

            // 播放/暂停按钮
            Button(action: viewModel.toggleTimer) {
                Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: 62, height: 62)
            .background(
                Circle()
                    .fill(currentThemeColor)
            )
        }
        .shadow(color: currentThemeColor.opacity(0.3), radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.3), value: viewModel.timeType)
    }

    private var stopButton: some View {
        ZStack {
            Circle()
                .stroke(currentThemeColor, lineWidth: 4)
                .opacity(0.3)

            Circle()
                .trim(from: viewModel.stopButtonProgress, to: 1.0)
                .stroke(
                    currentThemeColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .animation(.linear(duration: 0.1), value: viewModel.stopButtonProgress)

            Button(action: {}) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(currentThemeColor.opacity(0.8))
            )
            .scaleEffect(viewModel.stopButtonProgress < 1.0 ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.stopButtonProgress)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if viewModel.isActive {
                            viewModel.startStopButtonHold()
                        }
                    }
                    .onEnded { _ in
                        viewModel.cancelStopButtonHold()
                    }
            )
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.timeType)
    }

    private var quickSelectSection: some View {
        QuickSelectButton(
            minutes: .constant(viewModel.selectedMinutes),
            onTap: {
                viewModel.showingTimePicker = true
            },
            timeType: .constant(viewModel.timeType),
            isActive: viewModel.isActive
        )
        .padding(.horizontal, 8)
    }

    private var timePickerModal: some View {
        TimePickerModal(
            isPresented: $viewModel.showingTimePicker,
            selectedTime: .constant(viewModel.selectedMinutes),
            selectedThemeType: .constant(viewModel.timeType),
            isActive: viewModel.isActive
        )
        .onChange(of: viewModel.selectedMinutes) { _, newValue in
            // 时间选择后的处理逻辑已在ViewModel中处理
        }
    }

    // MARK: - Computed Properties

    private var currentThemeColor: Color {
        ThemeColorHelper.color(for: viewModel.timeType)
    }

    private var contrastTextColor: Color {
        ThemeColorHelper.contrastTextColor(for: viewModel.timeType)
    }
}

// MARK: - Configuration Helper
enum AppConfig {
    enum UI {
        static let appTitle = "番茄闹钟"
        static let timerCircleSize: CGFloat = 250
    }

    enum Colors {
        static let backgroundGradient = [
            Color(red: 1.0, green: 0.95, blue: 0.97),
            Color(red: 1.0, green: 0.9, blue: 0.95)
        ]
        static let titleColor = Color(red: 0.4, green: 0.3, blue: 0.4)
    }
}

// MARK: - Theme Color Helper
enum ThemeColorHelper {
    static func color(for timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) -> Color {
        switch timeType {
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

    static func contrastTextColor(for timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) -> Color {
        switch timeType {
        case .work, .longBreak, .focus45, .focus60, .custom:
            return .white
        case .shortBreak, .break10, .break20:
            return Color(red: 0.2, green: 0.4, blue: 0.3)
        }
    }
}

// MARK: - Preview
#Preview {
    PomodoroContentView()
}