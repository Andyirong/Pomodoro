//
//  TimerView.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var longPressProgress: Double = 0
    @State private var isLongPressing = false
    @GestureState private var isDetectingLongPress = false

    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                Color.pinkGradient
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    // 顶部导航栏
                    topNavigationBar

                    Spacer()

                    // 卡通助手区域
                    assistantCharacterArea

                    // 倒计时显示区域
                    timerDisplayArea

                    // 控制按钮区域
                    controlButtonsArea

                    // 快速时间选择
                    quickTimeSelection

                    // 历史记录预览
                    historyPreview

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .timerCompleted)) { _ in
                // 播放完成音效
                playCompletionSound()
            }
        }
    }

    // MARK: - 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            // 菜单按钮
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
            }
            .iconButtonStyle()

            Spacer()

            // 标题
            Text("番茄闹钟")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Spacer()

            // 统计按钮
            Button(action: {
                // TODO: 打开统计页面
            }) {
                Image(systemName: "chart.bar")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
            }
            .iconButtonStyle()
        }
    }

    // MARK: - 卡通助手区域
    private var assistantCharacterArea: some View {
        VStack(spacing: 10) {
            // TODO: 实现卡通助手视图
            Text("🌸")
                .font(.system(size: 80))
                .bounceEffect()
                .overlay(
                    Text(timerViewModel.isActive ? "💪" : "😊")
                        .font(.system(size: 40))
                        .offset(y: timerViewModel.isActive ? 0 : -20)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: timerViewModel.isActive)
                )

            Text(timerViewModel.isActive ? "专注中..." : "准备好开始了吗？")
                .font(.headline)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 20)
    }

    // MARK: - 倒计时显示区域
    private var timerDisplayArea: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color.progressBackground, lineWidth: 12)
                .frame(width: 250, height: 250)

            // 进度圆环
            Circle()
                .trim(from: 0, to: timerViewModel.progress)
                .stroke(
                    Color.progressFill,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerViewModel.progress)

            // 时间显示
            VStack(spacing: 10) {
                Text(timerViewModel.displayTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                // 当前设置备注
                if !timerViewModel.currentNote.isEmpty {
                    Text(timerViewModel.currentNote)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.secondaryButton)
                        .cornerRadius(8)
                }
            }
        }
        .cardStyle(cornerRadius: 125, shadowRadius: 10)
        .onTapGesture {
            if timerViewModel.canStart {
                timerViewModel.start()
            } else if timerViewModel.canPause {
                timerViewModel.pause()
            } else if timerViewModel.canResume {
                timerViewModel.resume()
            }
        }
    }

    // MARK: - 控制按钮区域
    private var controlButtonsArea: some View {
        HStack(spacing: 20) {
            // 重置按钮
            Button(action: {
                timerViewModel.reset()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
            .iconButtonStyle(backgroundColor: timerViewModel.canReset ? Color.secondaryButton : Color.secondaryText.opacity(0.3))
            .disabled(!timerViewModel.canReset)

            // 开始/暂停/继续按钮
            Button(action: {
                if timerViewModel.canStart {
                    timerViewModel.start()
                } else if timerViewModel.canPause {
                    timerViewModel.pause()
                } else if timerViewModel.canResume {
                    timerViewModel.resume()
                }
            }) {
                Image(systemName: timerViewModel.isActive && !timerViewModel.isPaused ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.textOnColor)
            }
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(timerViewModel.canStart || timerViewModel.canPause || timerViewModel.canResume ? Color.primaryButton : Color.secondaryText.opacity(0.3))
            )
            .shadow(color: Color.cardShadow, radius: 5, x: 0, y: 2)
            .disabled(!(timerViewModel.canStart || timerViewModel.canPause || timerViewModel.canResume))

            // 长按停止按钮
            ZStack {
                Button(action: {
                    // 这个按钮通过长按手势触发
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.textOnColor)
                }
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.errorColor)
                        .opacity(timerViewModel.isActive ? 1.0 : 0.3)
                )
                .scaleEffect(isLongPressing ? 1.1 : 1.0)
                .disabled(!timerViewModel.isActive)

                // 长按进度环
                if isLongPressing {
                    Circle()
                        .trim(from: 0, to: longPressProgress)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 3.0, maximumDistance: 50)
                    .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                        gestureState = currentState
                        transaction.animation = Animation.linear(duration: 0.1)
                    }
                    .onChanged { _ in
                        isLongPressing = true
                        withAnimation(.linear(duration: 3.0)) {
                            longPressProgress = 1.0
                        }
                    }
                    .onEnded { _ in
                        if longPressProgress >= 1.0 {
                            timerViewModel.stop(longPress: true)
                            // 播放停止音效
                            playStopSound()
                        }
                        isLongPressing = false
                        longPressProgress = 0
                    }
            )
        }
    }

    // MARK: - 快速时间选择
    private var quickTimeSelection: some View {
        VStack(spacing: 15) {
            Text("快速选择")
                .font(.headline)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach([15, 25, 30, 45, 60, 90], id: \.self) { minutes in
                    Button(action: {
                        timerViewModel.setQuickTime(minutes)
                    }) {
                        Text("\(minutes)分")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(height: 40)
                    .cardStyle(cornerRadius: 10, shadowRadius: 3)
                    .disabled(timerViewModel.isActive)
                }
            }
        }
    }

    // MARK: - 历史记录预览
    private var historyPreview: some View {
        VStack(spacing: 15) {
            HStack {
                Text("最近使用")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: {
                    showingHistory = true
                }) {
                    Text("查看全部")
                        .font(.caption)
                        .foregroundColor(.primaryButton)
                }
            }

            if !timerViewModel.recentSettings.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(timerViewModel.recentSettings.prefix(5)) { setting in
                            Button(action: {
                                timerViewModel.loadSetting(setting)
                            }) {
                                VStack(spacing: 4) {
                                    Text(setting.displayTime)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.textPrimary)

                                    if !setting.note.isEmpty {
                                        Text(setting.note)
                                            .font(.caption2)
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .cardStyle(cornerRadius: 12, shadowRadius: 3)
                            }
                            .disabled(timerViewModel.isActive)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            } else {
                Text("暂无历史记录")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
    }

    // MARK: - 辅助方法
    private func playCompletionSound() {
        // TODO: 实现音效播放
        print("🔔 计时完成！")
    }

    private func playStopSound() {
        // TODO: 实现音效播放
        print("⏹️ 计时停止")
    }
}

#Preview {
    TimerView()
}