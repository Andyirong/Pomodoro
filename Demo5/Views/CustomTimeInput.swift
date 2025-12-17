//
//  CustomTimeInput.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

// MARK: - 自定义时间输入组件
struct CustomTimeInput: View {
    // MARK: - 回调函数
    let onTimeSelected: (Int) -> Void  // 返回总分钟数
    let onCancel: () -> Void

    // MARK: - 状态变量
    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var selectedQuickTime: Int? = nil
    @State private var showHourError = false
    @State private var showMinuteError = false
    @State private var isEditingHour = false
    @State private var isEditingMinute = false

    // 快速选择选项
    private let quickTimes = [5, 10, 15, 30, 45, 60]

    // MARK: - 计算属性
    private var totalMinutes: Int {
        let h = Int(hours) ?? 0
        let m = Int(minutes) ?? 0
        return h * 60 + m
    }

    private var isInputValid: Bool {
        let h = Int(hours) ?? 0
        let m = Int(minutes) ?? 0
        return h >= 0 && h <= 23 && m >= 0 && m <= 59 && (h > 0 || m > 0)
    }

    // MARK: - 主体视图
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            Text("自定义时间")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .padding(.top, 10)

            // 时间输入区域
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    // 小时输入
                    VStack(alignment: .leading, spacing: 6) {
                        Text("小时")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.textSecondary)

                        TextField("0-23", text: $hours)
                            .keyboardType(.numberPad)
                            .themeTextFieldStyle(isEditing: isEditingHour)
                            .onTapGesture {
                                isEditingHour = true
                                isEditingMinute = false
                            }
                            .onChange(of: hours) { oldValue, newValue in
                                validateHourInput(newValue)
                            }
                    }

                    Text(":")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                        .padding(.top, 20)

                    // 分钟输入
                    VStack(alignment: .leading, spacing: 6) {
                        Text("分钟")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.textSecondary)

                        TextField("0-59", text: $minutes)
                            .keyboardType(.numberPad)
                            .themeTextFieldStyle(isEditing: isEditingMinute)
                            .onTapGesture {
                                isEditingMinute = true
                                isEditingHour = false
                            }
                            .onChange(of: minutes) { oldValue, newValue in
                                validateMinuteInput(newValue)
                            }
                    }
                }
                .padding(.horizontal, 4)

                // 错误提示
                if showHourError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.errorColor)
                            .font(.system(size: 12))
                        Text("小时必须在 0-23 之间")
                            .font(.system(size: 12))
                            .foregroundColor(Color.errorColor)
                    }
                    .transition(.opacity)
                }

                if showMinuteError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.errorColor)
                            .font(.system(size: 12))
                        Text("分钟必须在 0-59 之间")
                            .font(.system(size: 12))
                            .foregroundColor(Color.errorColor)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)

            // 分隔线
            Rectangle()
                .fill(Color.secondaryText.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // 快速选择区域
            VStack(alignment: .leading, spacing: 12) {
                Text("快速选择")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(quickTimes, id: \.self) { time in
                        QuickTimeButton(
                            minutes: time,
                            isSelected: selectedQuickTime == time,
                            onTap: {
                                selectQuickTime(time)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            // 总时间显示
            if totalMinutes > 0 && isInputValid {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color.primaryButton)
                        .font(.system(size: 14))
                    Text("总计: \(formatTime(totalMinutes))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.primaryButton)
                }
                .padding(.horizontal, 20)
                .transition(.opacity)
            }

            Spacer(minLength: 20)

            // 按钮区域
            HStack(spacing: 16) {
                // 取消按钮
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onCancel()
                }) {
                    Text("取消")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.secondaryButton)
                        )
                }
                .secondaryButtonStyle()

                // 确认按钮
                Button(action: {
                    if isInputValid {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        onTimeSelected(totalMinutes)
                    }
                }) {
                    Text("确认")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.textOnColor)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isInputValid ? Color.primaryButton : Color.secondaryText)
                        )
                }
                .primaryButtonStyle(isEnabled: isInputValid)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardBackground)
                .shadow(color: Color.cardShadow, radius: 10, x: 0, y: 5)
        )
        .onTapGesture {
            // 点击空白处取消键盘焦点
            isEditingHour = false
            isEditingMinute = false
            hideKeyboard()
        }
    }

    // MARK: - 方法

    private func validateHourInput(_ value: String) {
        // 只允许数字
        let filtered = value.filter { $0.isNumber }
        if filtered != value {
            hours = filtered
            return
        }

        // 检查范围
        if let hour = Int(filtered), hour > 23 {
            showHourError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showHourError = false
            }
        } else {
            showHourError = false
        }
    }

    private func validateMinuteInput(_ value: String) {
        // 只允许数字
        let filtered = value.filter { $0.isNumber }
        if filtered != value {
            minutes = filtered
            return
        }

        // 检查范围
        if let minute = Int(filtered), minute > 59 {
            showMinuteError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showMinuteError = false
            }
        } else {
            showMinuteError = false
        }
    }

    private func selectQuickTime(_ totalMinutes: Int) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // 添加触觉反馈和动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedQuickTime = totalMinutes
        }

        // 更新输入框
        let h = totalMinutes / 60
        let m = totalMinutes % 60

        if h > 0 {
            hours = "\(h)"
        } else {
            hours = ""
        }

        if m > 0 || h == 0 {
            self.minutes = "\(m)"
        } else {
            self.minutes = ""
        }

        // 清除错误状态
        showHourError = false
        showMinuteError = false
    }

    private func formatTime(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)小时\(minutes)分钟"
            } else {
                return "\(hours)小时"
            }
        } else {
            return "\(minutes)分钟"
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 快速时间按钮
struct QuickTimeButton: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }

            onTap()
        }) {
            Text("\(minutes)分钟")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? Color.textOnColor : Color.textPrimary)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.primaryButton, Color.primaryButton.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.clear : Color.primaryButton.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.primaryButton.opacity(0.3) : Color.cardShadow,
                            radius: isSelected ? 6 : 3,
                            x: 0,
                            y: isSelected ? 3 : 2
                        )
                        .opacity(isPressed ? 0.85 : 1.0)
                )
                .scaleEffect(isPressed ? 0.96 : (isSelected ? 1.02 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(
            .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0),
            value: isPressed
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: isSelected
        )
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 30) {
        CustomTimeInput(
            onTimeSelected: { minutes in
                print("选择了 \(minutes) 分钟")
            },
            onCancel: {
                print("取消了选择")
            }
        )
        .frame(height: 500)
        .padding()
    }
    .background(Color.themePink)
}