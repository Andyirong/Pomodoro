//
//  TimePickerModal.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

// MARK: - 时间选项数据模型
struct TimeOption {
    let minutes: Int
    let title: String
    let type: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType
}

// MARK: - 时间选择器弹窗组件
struct TimePickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedTime: Int
    @Binding var selectedThemeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType
    @State private var offsetY: CGFloat = 1000
    @State private var dragOffset: CGFloat = 0
    @State private var showingCustomTimeInput = false
    let isActive: Bool

    // 时间选项数据
    private let timeOptions: [TimeOption] = [
        TimeOption(minutes: 25, title: "工作时间", type: .work),
        TimeOption(minutes: 45, title: "专注45分钟", type: .focus45),
        TimeOption(minutes: 60, title: "专注60分钟", type: .focus60),
        TimeOption(minutes: 5, title: "短休息", type: .shortBreak),
        TimeOption(minutes: 10, title: "休息10分钟", type: .break10),
        TimeOption(minutes: 15, title: "长休息", type: .longBreak),
        TimeOption(minutes: 20, title: "休息20分钟", type: .break20)
    ]

    var body: some View {
        ZStack {
            // 背景模糊效果
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissModal()
                    }
                    .blur(radius: isPresented ? 2 : 0)
            }

            // 弹窗内容
            VStack(spacing: 0) {
                Spacer()

                // 拖动手柄
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.textSecondary.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // 标题栏
                HStack {
                    Text("选择时间")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)

                    Spacer()

                    // 关闭按钮
                    Button(action: dismissModal) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.secondaryButton)
                            )
                    }
                    .iconButtonStyle()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // 时间选项网格 (2x3)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 16
                ) {
                    // 前6个选项
                    ForEach(Array(timeOptions.prefix(6).enumerated()), id: \.offset) { index, option in
                        TimeOptionButton(
                            option: option,
                            isSelected: selectedTime == option.minutes,
                            isActive: isActive,
                            action: {
                                selectTimeOption(option)
                            }
                        )
                    }

                    // 自定义按钮
                    TimeOptionButton(
                        option: TimeOption(minutes: 0, title: "自定义", type: .custom),
                        isSelected: false,
                        isActive: isActive,
                        isCustom: true,
                        action: {
                            showingCustomTimeInput = true
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // 额外选项区域（可折叠）
                if !timeOptions.suffix(from: 6).isEmpty {
                    VStack(spacing: 16) {
                        Divider()
                            .background(Color.textSecondary.opacity(0.2))

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 16
                        ) {
                            ForEach(Array(timeOptions.suffix(from: 6).enumerated()), id: \.offset) { index, option in
                                TimeOptionButton(
                                    option: option,
                                    isSelected: selectedTime == option.minutes,
                                    isActive: isActive,
                                    action: {
                                        selectTimeOption(option)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                // 底部安全区域
                GeometryReader { geometry in
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.bottom)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
            )
            .offset(y: offsetY + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if value.translation.height > 100 {
                                dismissModal()
                            } else {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPresented)
        .onChange(of: isPresented) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offsetY = newValue ? 0 : 1000
            }
        }
        .onAppear {
            if isPresented {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    offsetY = 0
                }
            }
        }
        .sheet(isPresented: $showingCustomTimeInput) {
            CustomTimeInput(
                onTimeSelected: { totalMinutes in
                    selectedTime = totalMinutes
                    selectedThemeType = .custom
                    showingCustomTimeInput = false
                    dismissModal()
                },
                onCancel: {
                    showingCustomTimeInput = false
                }
            )
        }
    }

    // MARK: - 私有方法
    private func dismissModal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offsetY = 1000
            dragOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }

    private func selectTimeOption(_ option: TimeOption) {
        selectedTime = option.minutes
        selectedThemeType = option.type
        dismissModal()
    }
}

// MARK: - 时间选项按钮组件
struct TimeOptionButton: View {
    let option: TimeOption
    let isSelected: Bool
    let isActive: Bool
    let isCustom: Bool
    let action: () -> Void

    init(option: TimeOption, isSelected: Bool, isActive: Bool, isCustom: Bool = false, action: @escaping () -> Void) {
        self.option = option
        self.isSelected = isSelected
        self.isActive = isActive
        self.isCustom = isCustom
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isCustom {
                    // 自定义按钮显示图标
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? Color.white : getTimeTypeColor())
                } else {
                    // 时间和单位
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(option.minutes)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .lineLimit(1)

                        Text("分钟")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .lineLimit(1)
                    }
                }

                Text(option.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isActive ? Color.textSecondary : (isSelected ? Color.white : getTimeTypeColor()))
        }
        .frame(height: 100)
        .beautifulQuickSelectButtonStyle(
            isSelected: isSelected,
            isEnabled: !isActive,
            timeType: option.type
        )
    }

    private func getTimeTypeColor() -> Color {
        switch option.type {
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
}


// MARK: - 预览
#Preview {
    VStack {
        Button("显示弹窗") {
            // 测试按钮
        }
        .padding()

        Spacer()
    }
    .background(Color.themePink)
    .overlay(
        TimePickerModal(
            isPresented: .constant(true),
            selectedTime: .constant(25),
            selectedThemeType: .constant(.work),
            isActive: false
        )
    )
}
