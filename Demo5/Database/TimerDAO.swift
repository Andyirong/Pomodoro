//
//  TimerDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite3

class TimerDAO {
    private let db: OpaquePointer?

    init() {
        db = DatabaseManager.shared.getDatabase()
    }

    // 插入新的倒计时记录
    func insertTimerSettings(_ settings: TimerSettings) -> Bool {
        var statement: OpaquePointer?
        let sql = """
            INSERT INTO timer_history (minutes, seconds, note, created_at, usage_count)
            VALUES (?, ?, ?, ?, ?);
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(settings.minutes))
            sqlite3_bind_int(statement, 2, Int32(settings.seconds))
            sqlite3_bind_text(statement, 3, settings.note, -1, nil)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: settings.createdAt)
            sqlite3_bind_text(statement, 4, dateString, -1, nil)

            sqlite3_bind_int(statement, 5, Int32(settings.usageCount))

            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }

        sqlite3_finalize(statement)
        return false
    }

    // 获取最近的倒计时记录（最多10条）
    func getRecentTimerSettings(limit: Int = 10) -> [TimerSettings] {
        var settings: [TimerSettings] = []
        var statement: OpaquePointer?
        let sql = "SELECT * FROM timer_history ORDER BY created_at DESC LIMIT ?;"

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(limit))

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let minutes = Int(sqlite3_column_int(statement, 1))
                let seconds = Int(sqlite3_column_int(statement, 2))

                let notePtr = sqlite3_column_text(statement, 3)
                let note = notePtr != nil ? String(cString: notePtr!) : ""

                let createdAtPtr = sqlite3_column_text(statement, 4)
                let createdAtString = createdAtPtr != nil ? String(cString: createdAtPtr!) : ""

                let usageCount = Int(sqlite3_column_int(statement, 5))

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let createdAt = formatter.date(from: createdAtString) ?? Date()

                var setting = TimerSettings(minutes: Int(minutes), seconds: Int(seconds), note: note)
                setting = TimerSettings(
                    minutes: Int(minutes),
                    seconds: Int(seconds),
                    note: note
                )

                settings.append(setting)
            }
        }

        sqlite3_finalize(statement)
        return settings
    }

    // 检查是否存在相同设置的记录，如果存在则更新使用次数
    func updateUsageCount(minutes: Int, seconds: Int) -> Bool {
        var statement: OpaquePointer?
        let sql = """
            UPDATE timer_history
            SET usage_count = usage_count + 1, created_at = ?
            WHERE minutes = ? AND seconds = ?
            ORDER BY created_at DESC
            LIMIT 1;
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: Date())
            sqlite3_bind_text(statement, 1, dateString, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(minutes))
            sqlite3_bind_int(statement, 3, Int32(seconds))

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        sqlite3_finalize(statement)
        return false
    }

    // 保存或更新倒计时设置
    func saveOrUpdateTimerSettings(_ settings: TimerSettings) -> Bool {
        // 首先尝试更新现有记录
        if updateUsageCount(minutes: settings.minutes, seconds: settings.seconds) {
            return true
        }

        // 如果没有找到相同设置，则插入新记录
        return insertTimerSettings(settings)
    }

    // 获取总完成数
    func getTotalCompletedCount() -> Int {
        var statement: OpaquePointer?
        let sql = "SELECT COUNT(*) FROM timer_history;"
        var count = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }

        sqlite3_finalize(statement)
        return count
    }

    // 获取今日完成数
    func getTodayCompletedCount() -> Int {
        var statement: OpaquePointer?
        let sql = """
            SELECT COUNT(*) FROM timer_history
            WHERE DATE(created_at) = DATE('now');
        """
        var count = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }

        sqlite3_finalize(statement)
        return count
    }

    // 获取总专注分钟数
    func getTotalFocusMinutes() -> Int {
        var statement: OpaquePointer?
        let sql = "SELECT SUM(minutes) FROM timer_history;"
        var totalMinutes = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalMinutes = Int(sqlite3_column_int(statement, 0))
            }
        }

        sqlite3_finalize(statement)
        return totalMinutes
    }
}