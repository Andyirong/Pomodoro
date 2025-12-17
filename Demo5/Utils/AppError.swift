//
//  AppError.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation

/// 应用程序错误类型
enum AppError: Error, LocalizedError {
    // MARK: - Database Errors
    case databaseConnectionFailed
    case databaseOperationFailed(String)
    case dataNotFound(String)
    case invalidDataFormat(String)

    // MARK: - Timer Errors
    case timerAlreadyRunning
    case timerNotRunning
    case invalidTimeRange
    case timerOperationFailed(String)

    // MARK: - Configuration Errors
    case configurationNotFound(String)
    case invalidConfiguration(String)

    // MARK: - Notification Errors
    case notificationPermissionDenied
    case notificationFailed(String)

    // MARK: - Validation Errors
    case invalidInput(String)
    case outOfRange(String, min: Int, max: Int)

    // MARK: - Network Errors
    case networkUnavailable
    case networkTimeout
    case serverError(Int)

    // MARK: - Unknown Error
    case unknown(Error)

    // MARK: - LocalizedError Implementation
    var errorDescription: String? {
        switch self {
        // Database Errors
        case .databaseConnectionFailed:
            return "数据库连接失败，请检查应用权限设置"
        case .databaseOperationFailed(let operation):
            return "数据库操作失败：\(operation)"
        case .dataNotFound(let data):
            return "找不到数据：\(data)"
        case .invalidDataFormat(let format):
            return "数据格式无效：\(format)"

        // Timer Errors
        case .timerAlreadyRunning:
            return "计时器已经在运行中"
        case .timerNotRunning:
            return "计时器未在运行"
        case .invalidTimeRange:
            return "时间范围无效，请检查输入"
        case .timerOperationFailed(let operation):
            return "计时器操作失败：\(operation)"

        // Configuration Errors
        case .configurationNotFound(let key):
            return "找不到配置项：\(key)"
        case .invalidConfiguration(let config):
            return "配置项无效：\(config)"

        // Notification Errors
        case .notificationPermissionDenied:
            return "通知权限被拒绝，请在设置中开启通知"
        case .notificationFailed(let reason):
            return "通知发送失败：\(reason)"

        // Validation Errors
        case .invalidInput(let input):
            return "输入无效：\(input)"
        case .outOfRange(let value, let min, let max):
            return "数值超出范围，\(value)应在\(min)到\(max)之间"

        // Network Errors
        case .networkUnavailable:
            return "网络连接不可用"
        case .networkTimeout:
            return "网络请求超时"
        case .serverError(let code):
            return "服务器错误：\(code)"

        // Unknown Error
        case .unknown(let error):
            return "未知错误：\(error.localizedDescription)"
        }
    }

    var failureReason: String? {
        switch self {
        case .databaseConnectionFailed:
            return "无法建立数据库连接"
        case .timerAlreadyRunning:
            return "计时器状态冲突"
        case .notificationPermissionDenied:
            return "用户未授权通知权限"
        default:
            return errorDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .databaseConnectionFailed:
            return "请重启应用，或检查设备存储空间"
        case .notificationPermissionDenied:
            return "请前往 设置 > 通知 > Pomodoro 开启通知权限"
        case .networkUnavailable:
            return "请检查网络连接"
        case .invalidInput:
            return "请检查输入格式"
        default:
            return "如问题持续存在，请联系技术支持"
        }
    }
}

// MARK: - Result Type Extensions
extension Result {
    /// 转换为AppError
    func mapErrorToAppError() -> Result<Success, AppError> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(AppError.unknown(error))
        }
    }
}

// MARK: - Error Handling Utilities
struct ErrorHandler {
    /// 处理并显示错误
    static func handle(_ error: Error,
                      title: String = "错误",
                      showAlert: Bool = true,
                      logger: Logger = DefaultLogger.shared) {
        let appError = AppError.unknown(error)

        // 记录错误日志
        logger.error("Error occurred: \(error.localizedDescription)",
                   category: .error,
                   extra: ["errorType": String(describing: type(of: error))])

        // 显示错误提示
        if showAlert {
            DispatchQueue.main.async {
                // 这里可以集成Toast或者Alert组件
                print("⚠️ \(title): \(appError.localizedDescription)")
            }
        }

        // 发送错误通知
        NotificationCenter.default.post(
            name: .appErrorOccurred,
            object: nil,
            userInfo: [
                "error": appError,
                "title": title
            ]
        )
    }

    /// 安全执行异步操作
    static func safeAsyncExecute<T>(
        _ operation: @escaping () async throws -> T,
        onSuccess: @escaping (T) -> Void,
        onError: @escaping (AppError) -> Void
    ) {
        Task {
            do {
                let result = try await operation()
                await MainActor.run {
                    onSuccess(result)
                }
            } catch {
                let appError = AppError.unknown(error)
                await MainActor.run {
                    onError(appError)
                }
            }
        }
    }
}

// MARK: - Logger Protocol
protocol Logger {
    func error(_ message: String, category: LogCategory, extra: [String: Any]?)
    func warning(_ message: String, category: LogCategory, extra: [String: Any]?)
    func info(_ message: String, category: LogCategory, extra: [String: Any]?)
    func debug(_ message: String, category: LogCategory, extra: [String: Any]?)
}

enum LogCategory {
    case general
    case error
    case performance
    case database
    case network
    case timer
}

// MARK: - Default Logger Implementation
class DefaultLogger: Logger {
    static let shared = DefaultLogger()

    private init() {}

    func error(_ message: String, category: LogCategory, extra: [String: Any]? = nil) {
        log("ERROR", message: message, category: category, extra: extra)
    }

    func warning(_ message: String, category: LogCategory, extra: [String: Any]? = nil) {
        log("WARNING", message: message, category: category, extra: extra)
    }

    func info(_ message: String, category: LogCategory, extra: [String: Any]? = nil) {
        log("INFO", message: message, category: category, extra: extra)
    }

    func debug(_ message: String, category: LogCategory, extra: [String: Any]? = nil) {
        #if DEBUG
        log("DEBUG", message: message, category: category, extra: extra)
        #endif
    }

    private func log(_ level: String, message: String, category: LogCategory, extra: [String: Any]?) {
        var logMessage = "[\(level)] [\(category)] \(message)"

        if let extra = extra {
            logMessage += " - Extra: \(extra)"
        }

        print(logMessage)

        // 在生产环境中，这里可以集成第三方日志服务
        // 如Crashlytics, Firebase Analytics等
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let appErrorOccurred = Notification.Name("appErrorOccurred")
}