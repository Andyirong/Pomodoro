//
//  StatsDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite3

class StatsDAO {
    private let db: OpaquePointer?

    init() {
        db = DatabaseManager.shared.getDatabase()
    }

    // 保存每日统计数据
    func saveDailyStats(date: Date, totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) -> Bool {
        var statement: OpaquePointer?
        let sql = """
            INSERT OR REPLACE INTO statistics (date, total_minutes, completed_tomatoes, tasks_done)
            VALUES (?, ?, ?, ?);
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)

            sqlite3_bind_text(statement, 1, dateString, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(totalMinutes))
            sqlite3_bind_int(statement, 3, Int32(completedTomatoes))
            sqlite3_bind_int(statement, 4, Int32(tasksDone))

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        sqlite3_finalize(statement)
        return false
    }

    // 获取指定日期的统计数据
    func getStatsForDate(_ date: Date) -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int)? {
        var statement: OpaquePointer?
        let sql = "SELECT * FROM statistics WHERE date = ?;"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, dateString, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                let totalMinutes = Int(sqlite3_column_int(statement, 1))
                let completedTomatoes = Int(sqlite3_column_int(statement, 2))
                let tasksDone = Int(sqlite3_column_int(statement, 3))

                sqlite3_finalize(statement)
                return (
                    totalMinutes: Int(totalMinutes),
                    completedTomatoes: Int(completedTomatoes),
                    tasksDone: Int(tasksDone)
                )
            }
        }

        sqlite3_finalize(statement)
        return nil
    }

    // 获取今日统计数据
    func getTodayStats() -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        return getStatsForDate(Date()) ?? (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
    }

    // 获取本周统计数据
    func getWeekStats() -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
        }

        return getStatsForDateRange(from: weekStart, to: now)
    }

    // 获取本月统计数据
    func getMonthStats() -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start else {
            return (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
        }

        return getStatsForDateRange(from: monthStart, to: now)
    }

    // 获取日期范围内的统计数据
    private func getStatsForDateRange(from startDate: Date, to endDate: Date) -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        var statement: OpaquePointer?
        let sql = """
            SELECT SUM(total_minutes), SUM(completed_tomatoes), SUM(tasks_done)
            FROM statistics
            WHERE date >= ? AND date <= ?;
        """

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)

        var totalMinutes = 0
        var completedTomatoes = 0
        var tasksDone = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, startDateString, -1, nil)
            sqlite3_bind_text(statement, 2, endDateString, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                totalMinutes = Int(sqlite3_column_int(statement, 0))
                completedTomatoes = Int(sqlite3_column_int(statement, 1))
                tasksDone = Int(sqlite3_column_int(statement, 2))
            }
        }

        sqlite3_finalize(statement)
        return (totalMinutes: totalMinutes, completedTomatoes: completedTomatoes, tasksDone: tasksDone)
    }

    // 获取最近7天的每日统计数据
    func getLast7DaysStats() -> [(date: String, totalMinutes: Int, completedTomatoes: Int, tasksDone: Int)] {
        var stats: [(String, Int, Int, Int)] = []
        var statement: OpaquePointer?
        let sql = """
            SELECT date, total_minutes, completed_tomatoes, tasks_done
            FROM statistics
            WHERE date >= DATE('now', '-7 days')
            ORDER BY date ASC;
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let datePtr = sqlite3_column_text(statement, 0)
                let date = datePtr != nil ? String(cString: datePtr!) : ""

                let totalMinutes = Int(sqlite3_column_int(statement, 1))
                let completedTomatoes = Int(sqlite3_column_int(statement, 2))
                let tasksDone = Int(sqlite3_column_int(statement, 3))

                stats.append((
                    date: date,
                    totalMinutes: Int(totalMinutes),
                    completedTomatoes: Int(completedTomatoes),
                    tasksDone: Int(tasksDone)
                ))
            }
        }

        sqlite3_finalize(statement)
        return stats
    }

    // 获取全部时间统计
    func getAllTimeStats() -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        var statement: OpaquePointer?
        let sql = "SELECT SUM(total_minutes), SUM(completed_tomatoes), SUM(tasks_done) FROM statistics;"

        var totalMinutes = 0
        var completedTomatoes = 0
        var tasksDone = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalMinutes = Int(sqlite3_column_int(statement, 0))
                completedTomatoes = Int(sqlite3_column_int(statement, 1))
                tasksDone = Int(sqlite3_column_int(statement, 2))
            }
        }

        sqlite3_finalize(statement)
        return (totalMinutes: totalMinutes, completedTomatoes: completedTomatoes, tasksDone: tasksDone)
    }
}