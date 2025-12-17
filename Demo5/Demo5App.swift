//
//  Demo5App.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI
import UserNotifications

@main
struct Demo5App: App {

    init() {
        setupApplication()
    }

    var body: some Scene {
        WindowGroup {
            PomodoroContentView()
        }
    }

    // MARK: - Private Methods

    private func setupApplication() {
        // 1. 初始化配置
        initializeConfiguration()

        // 2. 初始化数据库
        initializeDatabase()

        // 3. 设置错误处理
        setupErrorHandling()

        // 4. 初始化通知
        initializeNotifications()
    }

    private func initializeConfiguration() {
        do {
            let config = AppConfiguration.shared
            try config.validate()

            // 从UserDefaults加载用户自定义配置
            config.loadFromUserDefaults()

            DefaultLogger.shared.info("App configuration initialized successfully", category: .general)
        } catch {
            ErrorHandler.handle(error,
                              title: "配置初始化失败",
                              showAlert: false)
        }
    }

    private func initializeDatabase() {
        // 暂时跳过数据库初始化，避免SQLite依赖问题
        DefaultLogger.shared.info("Database initialization skipped (using UserDefaults)", category: .database)

        // 可以在这里设置一些默认的用户设置
        if UserDefaults.standard.object(forKey: "default_minutes") == nil {
            UserDefaults.standard.set(25, forKey: "default_minutes")
        }
        if UserDefaults.standard.object(forKey: "default_time_type") == nil {
            UserDefaults.standard.set("work", forKey: "default_time_type")
        }
    }

    private func setupErrorHandling() {
        // 监听应用错误通知
        NotificationCenter.default.addObserver(
            forName: .appErrorOccurred,
            object: nil,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?["error"] as? AppError,
               let title = notification.userInfo?["title"] as? String {
                // 这里可以显示全局错误提示
                DefaultLogger.shared.error("Global error: \(error.localizedDescription)",
                                         category: .error,
                                         extra: ["title": title])
            }
        }
    }

    private func initializeNotifications() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    DefaultLogger.shared.info("Notification permission granted", category: .general)
                } else {
                    ErrorHandler.handle(AppError.notificationPermissionDenied,
                                      title: "通知权限",
                                      showAlert: false)
                }

                if let error = error {
                    ErrorHandler.handle(error,
                                      title: "通知权限请求",
                                      showAlert: false)
                }
            }
        }
    }
}
