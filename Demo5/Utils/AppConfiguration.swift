//
//  AppConfiguration.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SwiftUI

/// 应用程序配置管理器 - 消除硬编码，集中管理配置
struct AppConfiguration {

    // MARK: - Shared Instance
    static let shared = AppConfiguration()

    // MARK: - Configuration Properties
    let ui: UIConfiguration
    let colors: ColorConfiguration
    let timer: TimerConfiguration
    let notifications: NotificationConfiguration
    let database: DatabaseConfiguration

    // MARK: - Initialization
    private init() {
        self.ui = UIConfiguration()
        self.colors = ColorConfiguration()
        self.timer = TimerConfiguration()
        self.notifications = NotificationConfiguration()
        self.database = DatabaseConfiguration()
    }

    // MARK: - Validation
    func validate() throws {
        try ui.validate()
        try timer.validate()
        try database.validate()
    }
}

// MARK: - UI Configuration
struct UIConfiguration {
    let appTitle: String
    let timerCircleSize: CGFloat
    let buttonAnimationDuration: Double
    let maxTimeMinutes: Int
    let quickSelectTimes: [Int]

    init() {
        self.appTitle = "番茄闹钟"
        self.timerCircleSize = 250
        self.buttonAnimationDuration = 0.3
        self.maxTimeMinutes = 180 // 3小时
        self.quickSelectTimes = [5, 10, 15, 25, 30, 45, 60, 90, 120]
    }

    func validate() throws {
        if timerCircleSize <= 0 {
            throw AppError.invalidConfiguration("timerCircleSize must be positive")
        }
        if buttonAnimationDuration < 0 {
            throw AppError.invalidConfiguration("buttonAnimationDuration must be non-negative")
        }
        if maxTimeMinutes <= 0 {
            throw AppError.invalidConfiguration("maxTimeMinutes must be positive")
        }
    }
}

// MARK: - Color Configuration
struct ColorConfiguration {
    let backgroundGradient: [Color]
    let titleColor: Color
    let themeColors: ThemeColors

    struct ThemeColors {
        let workPink: Color
        let breakMint: Color
        let longBreakPurple: Color
        let focusDeepPink: Color
        let breakLightMint: Color
        let customPurple: Color

        init() {
            // 使用十六进制颜色代码，便于维护
            self.workPink = Color(hex: "#F3D4DD")
            self.breakMint = Color(hex: "#D4E8E0")
            self.longBreakPurple = Color(hex: "#E8D4E8")
            self.focusDeepPink = Color(hex: "#FF6B9D")
            self.breakLightMint = Color(hex: "#E8F3F0")
            self.customPurple = Color(hex: "#D4D4E8")
        }
    }

    init() {
        self.backgroundGradient = [
            Color(hex: "#FFF5F7"),
            Color(hex: "#FFE6EC")
        ]
        self.titleColor = Color(hex: "#664D4D")
        self.themeColors = ThemeColors()
    }

    func color(for timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) -> Color {
        switch timeType {
        case .work:
            return themeColors.workPink
        case .shortBreak:
            return themeColors.breakMint
        case .longBreak:
            return themeColors.longBreakPurple
        case .focus45, .focus60:
            return themeColors.focusDeepPink
        case .break10, .break20:
            return themeColors.breakLightMint
        case .custom:
            return themeColors.customPurple
        }
    }

    func contrastTextColor(for timeType: ThemeStyles.BeautifulQuickSelectButtonStyle.TimeType) -> Color {
        switch timeType {
        case .work, .longBreak, .focus45, .focus60, .custom:
            return .white
        case .shortBreak, .break10, .break20:
            return Color(hex: "#336644")
        }
    }
}

// MARK: - Timer Configuration
struct TimerConfiguration {
    let defaultMinutes: Int
    let defaultSeconds: Int
    let tickInterval: TimeInterval
    let longPressDuration: TimeInterval
    let completionVibrationPattern: [NSNumber]

    init() {
        self.defaultMinutes = 25
        self.defaultSeconds = 0
        self.tickInterval = 1.0
        self.longPressDuration = 3.0
        self.completionVibrationPattern = [0, 100, 100, 100, 100, 500] // 震动模式
    }

    func validate() throws {
        if defaultMinutes < 0 || defaultMinutes > 180 {
            throw AppError.invalidConfiguration("defaultMinutes must be between 0 and 180")
        }
        if defaultSeconds < 0 || defaultSeconds >= 60 {
            throw AppError.invalidConfiguration("defaultSeconds must be between 0 and 59")
        }
        if tickInterval <= 0 {
            throw AppError.invalidConfiguration("tickInterval must be positive")
        }
    }
}

// MARK: - Notification Configuration
struct NotificationConfiguration {
    let enableSound: Bool
    let enableVibration: Bool
    let enableBanner: Bool
    let defaultSoundName: String
    let completionMessage: String

    init() {
        self.enableSound = true
        self.enableVibration = true
        self.enableBanner = true
        self.defaultSoundName = "system_sound"
        self.completionMessage = "番茄钟已完成！"
    }
}

// MARK: - Database Configuration
struct DatabaseConfiguration {
    let databaseName: String
    let maxConnections: Int
    let connectionTimeout: TimeInterval
    let enableWALMode: Bool
    let enableForeignKeys: Bool

    init() {
        self.databaseName = "PomodoroDatabase.sqlite"
        self.maxConnections = 5
        self.connectionTimeout = 30.0
        self.enableWALMode = true
        self.enableForeignKeys = true
    }

    func validate() throws {
        if maxConnections <= 0 {
            throw AppError.invalidConfiguration("maxConnections must be positive")
        }
        if connectionTimeout <= 0 {
            throw AppError.invalidConfiguration("connectionTimeout must be positive")
        }
    }
}

// MARK: - UserDefaults Manager
class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Generic Methods
    func set<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func get<T>(_ type: T.Type, forKey key: String, defaultValue: T) -> T {
        guard let value = userDefaults.object(forKey: key) as? T else {
            return defaultValue
        }
        return value
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    // MARK: - Configuration Methods
    func saveAppConfiguration(_ config: AppConfiguration) {
        let configData: [String: Any] = [
            "timer.defaultMinutes": config.timer.defaultMinutes,
            "timer.defaultSeconds": config.timer.defaultSeconds,
            "notifications.enableSound": config.notifications.enableSound,
            "notifications.enableVibration": config.notifications.enableVibration,
            "ui.maxTimeMinutes": config.ui.maxTimeMinutes
        ]

        for (key, value) in configData {
            userDefaults.set(value, forKey: key)
        }
    }

    func loadAppConfiguration() -> AppConfiguration? {
        // 实现从UserDefaults加载配置的逻辑
        // 这里简化处理，实际可以更复杂
        return nil
    }
}

// MARK: - Color Extension for Hex Support
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

// MARK: - Configuration Validation
extension AppConfiguration {
    func loadFromUserDefaults() {
        let defaults = UserDefaultsManager.shared

        // 更新配置基于用户设置
        // 这里可以实现用户自定义配置的加载
    }

    func saveToUserDefaults() {
        let defaults = UserDefaultsManager.shared
        defaults.saveAppConfiguration(self)
    }
}