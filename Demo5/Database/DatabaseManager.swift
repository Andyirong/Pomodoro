//
//  DatabaseManager.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private init() {}

    func openDatabase() -> Bool {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("PomodoroDatabase.sqlite")

            db = try Connection(fileURL.path)

            // 优化数据库设置
            try db?.execute("PRAGMA foreign_keys = ON")
            try db?.execute("PRAGMA journal_mode = WAL")
            try db?.execute("PRAGMA synchronous = NORMAL")

            try createTables()

            print("✅ 数据库连接成功")
            return true
        } catch {
            print("❌ 数据库打开失败: \(error)")
            return false
        }
    }

    private func createTables() throws {
        guard let db = db else { throw DatabaseError.notConnected }

        // 创建 timer_history 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS timer_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                minutes INTEGER NOT NULL,
                seconds INTEGER NOT NULL,
                note TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                usage_count INTEGER DEFAULT 1
            );
        """)

        // 创建 tasks 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                category TEXT,
                priority INTEGER DEFAULT 1,
                deadline DATETIME,
                completed INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                completed_at DATETIME
            );
        """)

        // 创建 user_settings 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS user_settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                total_points INTEGER DEFAULT 0,
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0
            );
        """)

        // 创建 achievements 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS achievements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                unlocked_at DATETIME,
                points_required INTEGER,
                points_awarded INTEGER
            );
        """)

        // 创建 statistics 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS statistics (
                date DATE PRIMARY KEY,
                total_minutes INTEGER DEFAULT 0,
                completed_tomatoes INTEGER DEFAULT 0,
                tasks_done INTEGER DEFAULT 0
            );
        """)

        // 添加缺失的列（用于数据库升级）
        try addMissingColumns()

        // 初始化默认设置
        initializeDefaultSettings()
        initializeDefaultAchievements()
    }

    private func addMissingColumns() throws {
        guard let db = db else { throw DatabaseError.notConnected }

        // 检查并添加 completed_at 列到 tasks 表
        do {
            // 尝试查询 completed_at 列是否存在
            _ = try db.scalar("SELECT completed_at FROM tasks LIMIT 1")
        } catch {
            // 如果列不存在，添加它
            try db.run("ALTER TABLE tasks ADD COLUMN completed_at DATETIME")
            print("✅ 添加 completed_at 列到 tasks 表")
        }
    }

    private func initializeDefaultSettings() {
        guard let db = db else { return }

        do {
            let count = try db.scalar("SELECT COUNT(*) FROM user_settings;") as! Int64

            if count == 0 {
                let defaultSettings: [(String, String)] = [
                    ("total_points", "0"),
                    ("current_streak", "0"),
                    ("longest_streak", "0"),
                    ("sound_enabled", "true"),
                    ("vibration_enabled", "true"),
                    ("default_minutes", "25"),
                    ("default_seconds", "0")
                ]

                for (key, value) in defaultSettings {
                    try db.run("INSERT INTO user_settings (key, value) VALUES (?, ?);", key, value)
                }
                print("✅ 默认设置初始化完成")
            }
        } catch {
            print("⚠️ 设置初始化失败: \(error)")
        }
    }

    private func initializeDefaultAchievements() {
        guard let db = db else { return }

        do {
            let count = try db.scalar("SELECT COUNT(*) FROM achievements;") as! Int64

            if count == 0 {
                let achievements = [
                    (1, "初学者", "完成第一个番茄钟", 1, 10),
                    (2, "专注入门", "累计完成10个番茄钟", 10, 50),
                    (3, "专注达人", "累计完成50个番茄钟", 50, 200),
                    (4, "专注大师", "累计完成100个番茄钟", 100, 500),
                    (5, "连续三天", "连续3天使用番茄钟", 0, 50),
                    (6, "连续一周", "连续7天使用番茄钟", 0, 100),
                    (7, "连续一月", "连续30天使用番茄钟", 0, 500),
                    (8, "积分新手", "累计获得100积分", 100, 20),
                    (9, "积分高手", "累计获得500积分", 500, 100),
                    (10, "积分大师", "累计获得1000积分", 1000, 200),
                    (11, "任务完成者", "完成10个任务", 10, 50),
                    (12, "高效工作者", "完成50个任务", 50, 200),
                    (13, "马拉松选手", "完成一次90分钟番茄钟", 1, 50),
                    (14, "早起鸟儿", "早上8点前完成番茄钟", 1, 30),
                    (15, "夜猫子", "晚上10点后完成番茄钟", 1, 30)
                ]

                for achievement in achievements {
                    try db.run("""
                        INSERT INTO achievements (id, name, description, points_required, points_awarded)
                        VALUES (?, ?, ?, ?, ?);
                    """, achievement.0, achievement.1, achievement.2, achievement.3, achievement.4)
                }
                print("✅ 默认成就初始化完成")
            }
        } catch {
            print("⚠️ 成就初始化失败: \(error)")
        }
    }

    func getDatabase() -> Connection? {
        return db
    }

    func closeDatabase() {
        db = nil
        print("📝 数据库连接已关闭")
    }

    // MARK: - 设置管理

    func getUserSetting(key: String, defaultValue: Any) -> String {
        do {
            guard let db = db else { return String(describing: defaultValue) }

            if let value = try db.scalar("SELECT value FROM user_settings WHERE key = ?;", key) {
                return value as? String ?? String(describing: defaultValue)
            }
        } catch {
            print("⚠️ 获取设置失败: \(error)")
        }
        return String(describing: defaultValue)
    }

    func setUserSetting(key: String, value: String) {
        do {
            guard let db = db else { return }

            try db.run("""
                INSERT OR REPLACE INTO user_settings (key, value)
                VALUES (?, ?);
            """, key, value)
        } catch {
            print("⚠️ 保存设置失败: \(error)")
        }
    }
}

enum DatabaseError: Error {
    case notConnected
    case operationFailed(String)
    case invalidQuery(String)
    case dataNotFound(String)

    var localizedDescription: String {
        switch self {
        case .notConnected:
            return "数据库未连接"
        case .operationFailed(let message):
            return "数据库操作失败: \(message)"
        case .invalidQuery(let query):
            return "无效的SQL查询: \(query)"
        case .dataNotFound(let data):
            return "找不到数据: \(data)"
        }
    }
}