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
                        .stroke(Color.white.opacity(0.5), lineWidth: 12)
                        .frame(width: 250, height: 250)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.7, blue: 0.8), Color(red: 0.85, green: 0.6, blue: 0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 10) {
                        Text(displayTime)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.4))

                        Text(isActive ? "专注中..." : "准备好开始了吗？")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.6))
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
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(red: 0.9, green: 0.85, blue: 0.9))
                    )
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.4))

                    // 开始/暂停按钮
                    Button(action: toggleTimer) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(Color(red: 0.95, green: 0.75, blue: 0.85))
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                    // 停止按钮
                    Button(action: stopTimer) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(red: 1.0, green: 0.75, blue: 0.75))
                    )
                }

                Spacer()

                // 快速时间选择
                VStack(spacing: 15) {
                    Text("快速选择")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.4))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach([15, 25, 30, 45, 60, 90], id: \.self) { mins in
                            Button(action: {
                                if !isActive {
                                    minutes = mins
                                    seconds = 0
                                    progress = 1.0
                                }
                            }) {
                                Text("\(mins)分")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.4))
                            }
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                            .disabled(isActive)
                        }
                    }
                }

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
