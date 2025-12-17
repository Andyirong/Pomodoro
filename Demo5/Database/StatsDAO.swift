//
//  StatsDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite

class StatsDAO {
    private let db: Connection

    // 表和列定义
    private let statistics = Table("statistics")
    private let dateColumn = Expression<String>("date")
    private let totalMinutes = Expression<Int>("total_minutes")
    private let completedTomatoes = Expression<Int>("completed_tomatoes")
    private let tasksDone = Expression<Int>("tasks_done")

    init() throws {
        guard let database = DatabaseManager.shared.getDatabase() else {
            throw DatabaseError.notConnected
        }
        db = database
    }

    // 保存每日统计数据
    func saveDailyStats(date: Date, totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let insertOrReplace = statistics.insert(or: .replace,
            dateColumn <- dateString,
            self.totalMinutes <- totalMinutes,
            self.completedTomatoes <- completedTomatoes,
            self.tasksDone <- tasksDone
        )

        try db.run(insertOrReplace)
    }

    // 获取指定日期的统计数据
    func getStatsForDate(_ date: Date) -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int)? {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)

            let query = statistics.filter(dateColumn == dateString)

            for row in try db.prepare(query) {
                return (
                    totalMinutes: row[totalMinutes],
                    completedTomatoes: row[completedTomatoes],
                    tasksDone: row[tasksDone]
                )
            }
            return nil
        } catch {
            print("获取指定日期统计数据失败: \(error)")
            return nil
        }
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
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startDateString = formatter.string(from: startDate)
            let endDateString = formatter.string(from: endDate)

            let query = statistics
                .filter(dateColumn >= startDateString && dateColumn <= endDateString)

            let totalMinutes = try db.scalar(query.select(totalMinutes.sum)) ?? 0
            let completedTomatoes = try db.scalar(query.select(completedTomatoes.sum)) ?? 0
            let tasksDone = try db.scalar(query.select(tasksDone.sum)) ?? 0

            return (totalMinutes: totalMinutes, completedTomatoes: completedTomatoes, tasksDone: tasksDone)
        } catch {
            print("获取日期范围内统计数据失败: \(error)")
            return (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
        }
    }

    // 获取最近7天的每日统计数据
    func getLast7DaysStats() -> [(date: Date, totalMinutes: Int, completedTomatoes: Int, tasksDone: Int)] {
        do {
            let calendar = Calendar.current
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let sevenDaysAgoString = formatter.string(from: sevenDaysAgo)

            let query = statistics
                .filter(dateColumn >= sevenDaysAgoString)
                .order(dateColumn.asc)

            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd"

            return try db.prepare(query).compactMap { row in
                let dateString = row[dateColumn]
                if let date = formatter2.date(from: dateString) {
                    return (
                        date: date,
                        totalMinutes: row[totalMinutes],
                        completedTomatoes: row[completedTomatoes],
                        tasksDone: row[tasksDone]
                    )
                }
                return nil
            }
        } catch {
            print("获取最近7天统计数据失败: \(error)")
            return []
        }
    }

    // 获取全部时间统计
    func getAllTimeStats() -> (totalMinutes: Int, completedTomatoes: Int, tasksDone: Int) {
        do {
            let totalMinutes = try db.scalar(statistics.select(totalMinutes.sum)) ?? 0
            let completedTomatoes = try db.scalar(statistics.select(completedTomatoes.sum)) ?? 0
            let tasksDone = try db.scalar(statistics.select(tasksDone.sum)) ?? 0

            return (totalMinutes: totalMinutes, completedTomatoes: completedTomatoes, tasksDone: tasksDone)
        } catch {
            print("获取全部时间统计失败: \(error)")
            return (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
        }
    }
}