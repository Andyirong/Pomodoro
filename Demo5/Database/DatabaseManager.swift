//
//  DatabaseManager.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {}

    func openDatabase() -> Bool {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PomodoroDatabase.sqlite")

        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            createTables()
            return true
        } else {
            print("Unable to open database")
            return false
        }
    }

    private func createTables() {
        // 创建 timer_history 表
        let createTimerHistoryTable = """
            CREATE TABLE IF NOT EXISTS timer_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                minutes INTEGER NOT NULL,
                seconds INTEGER NOT NULL,
                note TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                usage_count INTEGER DEFAULT 1
            );
        """

        // 创建 tasks 表
        let createTasksTable = """
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                category TEXT,
                priority INTEGER DEFAULT 1,
                deadline DATETIME,
                completed BOOLEAN DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
        """

        // 创建 user_settings 表
        let createUserSettingsTable = """
            CREATE TABLE IF NOT EXISTS user_settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                total_points INTEGER DEFAULT 0,
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0
            );
        """

        // 创建 achievements 表
        let createAchievementsTable = """
            CREATE TABLE IF NOT EXISTS achievements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                unlocked_at DATETIME,
                points_required INTEGER,
                points_awarded INTEGER
            );
        """

        // 创建 statistics 表
        let createStatisticsTable = """
            CREATE TABLE IF NOT EXISTS statistics (
                date DATE PRIMARY KEY,
                total_minutes INTEGER DEFAULT 0,
                completed_tomatoes INTEGER DEFAULT 0,
                tasks_done INTEGER DEFAULT 0
            );
        """

        executeSQL(createTimerHistoryTable)
        executeSQL(createTasksTable)
        executeSQL(createUserSettingsTable)
        executeSQL(createAchievementsTable)
        executeSQL(createStatisticsTable)

        // 初始化默认设置
        initializeDefaultSettings()
    }

    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    private func initializeDefaultSettings() {
        // 检查是否已有设置
        let checkSQL = "SELECT COUNT(*) FROM user_settings;"
        var statement: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, checkSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        // 如果没有设置，插入默认值
        if count == 0 {
            let defaultSettings = [
                ("total_points", "0"),
                ("current_streak", "0"),
                ("longest_streak", "0"),
                ("sound_enabled", "true"),
                ("vibration_enabled", "true"),
                ("default_minutes", "25"),
                ("default_seconds", "0")
            ]

            for (key, value) in defaultSettings {
                let insertSQL = "INSERT INTO user_settings (key, value) VALUES ('\(key)', '\(value)');"
                executeSQL(insertSQL)
            }
        }
    }

    func getDatabase() -> OpaquePointer? {
        return db
    }

    func closeDatabase() {
        sqlite3_close(db)
    }
}