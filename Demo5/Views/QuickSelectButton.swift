//
//  QuickSelectButton.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

// MARK: - 快速选择按钮组件
struct QuickSelectButton: View {
    @Binding var minutes: Int  // 显示的时间（分钟）
    let onTap: () -> Void  // 点击回调
    @Binding var timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType  // 时间类型
    let isActive: Bool  // 计时器是否正在进行

    @State private var isPressed = false
    @State private var isPulsing = false
    @State private var displayedMinutes: Int  // 用于动画过渡的显示值

    init(minutes: Binding<Int>, onTap: @escaping () -> Void, timeType: Binding<ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType>, isActive: Bool) {
        self._minutes = minutes
        self.onTap = onTap
        self._timeType = timeType
        self.isActive = isActive
        self._displayedMinutes = State(initialValue: minutes.wrappedValue)
    }

    var body: some View {
        Button(action: {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()

            // 触发点击动画
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }

            // 执行回调
            onTap()
        }) {
            HStack(spacing: 8) {
                // 时间和单位
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(displayedMinutes)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("分钟")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }

                // 箭头图标
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .rotationEffect(.degrees(isPressed ? 180 : 0))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [getTimeTypeColor(), getTimeTypeColor().opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: getTimeTypeColor().opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .scaleEffect(isPressed ? 0.95 : (isPulsing ? 1.05 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // 初始化显示的分钟数
            displayedMinutes = minutes

            // 添加持续的脉冲动画
            if !isActive {
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
        }
        .onChange(of: minutes) { _, newValue in
            // 平滑过渡到新的时间值
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                displayedMinutes = newValue
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                // 计时器开始时停止脉冲
                withAnimation(.easeOut(duration: 0.3)) {
                    isPulsing = false
                }
            } else {
                // 计时器停止时恢复脉冲
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
        }
    }

    // 根据时间类型获取对应的主题颜色
    private func getTimeTypeColor() -> Color {
        switch timeType {
        case .work:
            return Color.themeWorkPink  // 工作时间粉色
        case .shortBreak:
            return Color.themeBreakMint  // 休息薄荷绿
        case .longBreak:
            return Color.themeLongBreakPurple  // 长休息淡紫
        case .focus45, .focus60:
            return Color.themeFocusDeepPink  // 专注时间深粉
        case .break10, .break20:
            return Color.themeBreakLightMint  // 休息时间浅薄荷
        case .custom:
            return Color.themeCustomPurple  // 自定义时间紫色
        }
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 30) {
        QuickSelectButton(
            minutes: .constant(25),
            onTap: {
                print("点击了25分钟按钮")
            },
            timeType: .constant(.work),
            isActive: false
        )

        QuickSelectButton(
            minutes: .constant(5),
            onTap: {
                print("点击了5分钟按钮")
            },
            timeType: .constant(.shortBreak),
            isActive: false
        )

        QuickSelectButton(
            minutes: .constant(15),
            onTap: {
                print("点击了15分钟按钮")
            },
            timeType: .constant(.longBreak),
            isActive: true
        )
    }
    .padding()
    .background(Color.themePink)
}
