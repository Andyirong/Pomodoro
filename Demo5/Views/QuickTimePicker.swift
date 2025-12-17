//
//  QuickTimePicker.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

// MARK: - 快速时间选择器组件
struct QuickTimePicker: View {
    @Binding var selectedTime: Int  // 选中的时间（分钟）
    @Binding var selectedThemeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType  // 选中的主题类型
    @State private var selectedIndex: Int = 0  // 当前选中索引
    let isActive: Bool  // 计时器是否正在进行

    // 标准番茄钟时间选项
    private let timeOptions: [TimeOption] = [
        TimeOption(minutes: 25, title: "工作时间", type: .work),
        TimeOption(minutes: 5, title: "短休息", type: .shortBreak),
        TimeOption(minutes: 15, title: "长休息", type: .longBreak)
    ]

    init(selectedTime: Binding<Int>, selectedThemeType: Binding<ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType>, isActive: Bool) {
        self._selectedTime = selectedTime
        self._selectedThemeType = selectedThemeType
        self.isActive = isActive
        // 初始化时找到对应的时间选项
        if let index = timeOptions.firstIndex(where: { $0.minutes == selectedTime.wrappedValue }) {
            self._selectedIndex = State(initialValue: index)
            self.selectedThemeType = selectedThemeType.wrappedValue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text("快速选择")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                Spacer()
                Text("点击选择时间")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // 快速选择按钮网格
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(Array(timeOptions.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        if !isActive {
                            selectedIndex = index
                            selectedTime = option.minutes
                            selectedThemeType = option.type
                        } else {
                            // 计时过程中也允许切换颜色
                            selectedIndex = index
                            selectedThemeType = option.type
                        }
                    }) {
                        VStack(spacing: 8) {
                            // 时间和单位在一行
                            HStack(spacing: 2) {
                                Text("\(option.minutes)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .lineLimit(1)

                                Text("分钟")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .lineLimit(1)
                            }

                            // 标题在第二行
                            Text(option.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isActive ? Color.textSecondary : (selectedIndex == index ? Color.white : getTimeTypeColor(option.type)))
                    }
                    .beautifulQuickSelectButtonStyle(
                        isSelected: selectedIndex == index,
                        isEnabled: !isActive,
                        timeType: option.type
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeLightPink.opacity(0.95))
                .shadow(color: Color.themeMainPink.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.3), value: selectedIndex)
    }

    private func getTimeTypeColor(_ type: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) -> Color {
        switch type {
        case .work:
            return Color.themeWorkPink
        case .shortBreak:
            return Color.themeBreakMint
        case .longBreak:
            return Color.themeLongBreakPurple
        }
    }
}

// MARK: - 时间选项数据模型
struct TimeOption {
    let minutes: Int
    let title: String
    let type: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        QuickTimePicker(
            selectedTime: .constant(25),
            selectedThemeType: .constant(.work),
            isActive: false
        )

        QuickTimePicker(
            selectedTime: .constant(5),
            selectedThemeType: .constant(.shortBreak),
            isActive: true
        )
    }
    .padding()
    .background(Color.themePink)
}