//
//  Color+Extensions.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

extension Color {
    // MARK: - 主题粉色系
    static let themePink = Color(red: 1.0, green: 0.9, blue: 0.95) // 粉色背景
    static let themeDarkPink = Color(red: 0.95, green: 0.7, blue: 0.8) // 深粉色
    static let themePurple = Color(red: 0.85, green: 0.7, blue: 0.95) // 紫色

    // MARK: - 马卡龙色系
    static let macaronPink = Color(red: 1.0, green: 0.85, blue: 0.9) // 马卡龙粉
    static let macaronMint = Color(red: 0.85, green: 0.95, blue: 0.9) // 薄荷绿
    static let macaronLavender = Color(red: 0.9, green: 0.85, blue: 0.95) // 薰衣草紫
    static let macaronPeach = Color(red: 1.0, green: 0.9, blue: 0.85) // 蜜桃橙
    static let macaronLemon = Color(red: 1.0, green: 0.98, blue: 0.85) // 柠檬黄

    // MARK: - 新主题色调（基于图片）
    static let themeMainPink = Color(red: 0.96, green: 0.82, blue: 0.86) // 主题粉色
    static let themeDeepPink = Color(red: 0.88, green: 0.68, blue: 0.74) // 深粉色
    static let themeLightPink = Color(red: 0.98, green: 0.92, blue: 0.94) // 浅粉色
    static let themeWorkPink = Color(red: 0.95, green: 0.83, blue: 0.87) // 工作时间粉色
    static let themeBreakMint = Color(red: 0.82, green: 0.89, blue: 0.86) // 休息薄荷绿
    static let themeLongBreakPurple = Color(red: 0.88, green: 0.83, blue: 0.90) // 长休息淡紫

    // MARK: - 扩展主题色调（新的时间类型）
    static let themeFocusDeepPink = Color(red: 0.85, green: 0.62, blue: 0.68) // 深专注色（更深一点的粉色）
    static let themeBreakLightMint = Color(red: 0.88, green: 0.94, blue: 0.91) // 浅休息色（更浅的薄荷绿）
    static let themeCustomPurple = Color(red: 0.82, green: 0.75, blue: 0.88) // 自定义时间色（独特的紫色）

    // MARK: - 渐变色
    static let pinkGradient = LinearGradient(
        colors: [themeLightPink, themePink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let purpleGradient = LinearGradient(
        colors: [themeLightPink, themePurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let macaronGradient = LinearGradient(
        colors: [macaronPink, macaronMint, macaronLavender],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - 功能性颜色
    static let primaryButton = Color(red: 0.95, green: 0.75, blue: 0.85) // 主按钮色
    static let secondaryButton = Color(red: 0.9, green: 0.85, blue: 0.9) // 次按钮色
    static let accentColor = Color(red: 0.85, green: 0.6, blue: 0.75) // 强调色

    // MARK: - 文本颜色
    static let primaryText = Color(red: 0.4, green: 0.3, blue: 0.4) // 主文本
    static let secondaryText = Color(red: 0.6, green: 0.5, blue: 0.6) // 次文本
    static let textOnColor = Color.white // 彩色背景上的文字

    // MARK: - 状态颜色
    static let successColor = Color(red: 0.7, green: 0.9, blue: 0.7) // 成功/完成
    static let warningColor = Color(red: 1.0, green: 0.85, blue: 0.5) // 警告
    static let errorColor = Color(red: 1.0, green: 0.75, blue: 0.75) // 错误
    static let infoColor = Color(red: 0.75, green: 0.85, blue: 1.0) // 信息

    // MARK: - 任务优先级颜色
    static let priorityHigh = Color(red: 1.0, green: 0.7, blue: 0.7) // 高优先级
    static let priorityMedium = Color(red: 1.0, green: 0.85, blue: 0.6) // 中优先级
    static let priorityLow = Color(red: 0.7, green: 1.0, blue: 0.7) // 低优先级

    // MARK: - 进度条颜色
    static let progressBackground = Color.white.opacity(0.5)
    static let progressFill = LinearGradient(
        colors: [themeDarkPink, accentColor],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - 卡片颜色
    static let cardBackground = Color.white.opacity(0.8)
    static let cardShadow = Color.black.opacity(0.1)

    // MARK: - 助手角色颜色
    static let characterSkin = Color(red: 1.0, green: 0.95, blue: 0.9) // 肌肤色
    static let characterBlush = Color(red: 1.0, green: 0.8, blue: 0.8) // 腮红
    static let characterHair = Color(red: 0.6, green: 0.4, blue: 0.3) // 头发色
    static let characterEye = Color(red: 0.4, green: 0.3, blue: 0.2) // 眼睛色

    // MARK: - 暗黑模式适配
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - 快速访问方法
    static var backgroundPrimary: Color {
        adaptiveColor(light: themeLightPink, dark: Color(red: 0.2, green: 0.15, blue: 0.2))
    }

    static var backgroundSecondary: Color {
        adaptiveColor(light: Color.white, dark: Color(red: 0.25, green: 0.2, blue: 0.25))
    }

    static var textPrimary: Color {
        adaptiveColor(light: primaryText, dark: Color.white)
    }

    static var textSecondary: Color {
        adaptiveColor(light: secondaryText, dark: Color.white.opacity(0.7))
    }
}

// MARK: - 自定义初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
