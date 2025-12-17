//
//  TimerDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite

class TimerDAO {
    private let db: Connection

    // 表和列定义
    private let timerHistory = Table("timer_history")
    private let id = Expression<Int64>("id")
    private let minutes = Expression<Int>("minutes")
    private let seconds = Expression<Int>("seconds")
    private let note = Expression<String>("note")
    private let createdAt = Expression<Date>("created_at")
    private let usageCount = Expression<Int>("usage_count")

    init() throws {
        guard let database = DatabaseManager.shared.getDatabase() else {
            throw DatabaseError.notConnected
        }
        db = database
    }

    // 插入新的倒计时记录
    func insertTimerSettings(_ settings: TimerSettings) throws -> Int64 {
        let insert = timerHistory.insert(
            minutes <- settings.minutes,
            seconds <- settings.seconds,
            note <- settings.note,
            createdAt <- settings.createdAt,
            usageCount <- settings.usageCount
        )
        return try db.run(insert)
    }

    // 获取最近的倒计时记录（最多10条）
    func getRecentTimerSettings(limit: Int = 10) -> [TimerSettings] {
        do {
            let query = timerHistory
                .order(createdAt.desc)
                .limit(limit)

            var settings: [TimerSettings] = []
            for row in try db.prepare(query) {
                let setting = TimerSettings(
                    dbId: row[id],
                    minutes: row[minutes],
                    seconds: row[seconds],
                    note: row[note],
                    createdAt: row[createdAt],
                    usageCount: row[usageCount]
                )
                settings.append(setting)
            }
            return settings
        } catch {
            print("获取最近记录失败: \(error)")
            return []
        }
    }

    // 检查是否存在相同设置的记录，如果存在则更新使用次数
    func updateUsageCount(minutes: Int, seconds: Int) -> Bool {
        do {
            let update = timerHistory
                .filter(self.minutes == minutes && self.seconds == seconds)
                .update(
                    usageCount += 1,
                    createdAt <- Date()
                )

            let changes = try db.run(update)
            return changes > 0
        } catch {
            print("更新使用次数失败: \(error)")
            return false
        }
    }

    // 保存或更新倒计时设置
    func saveOrUpdateTimerSettings(_ settings: TimerSettings) -> Bool {
        // 首先尝试更新现有记录
        if updateUsageCount(minutes: settings.minutes, seconds: settings.seconds) {
            return true
        }

        // 如果没有找到相同设置，则插入新记录
        do {
            _ = try insertTimerSettings(settings)
            return true
        } catch {
            print("插入记录失败: \(error)")
            return false
        }
    }

    // 获取总完成数
    func getTotalCompletedCount() -> Int {
        do {
            return try db.scalar(timerHistory.count)
        } catch {
            print("获取总完成数失败: \(error)")
            return 0
        }
    }

    // 获取今日完成数
    func getTodayCompletedCount() -> Int {
        do {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let query = timerHistory.filter(
                createdAt >= startOfDay && createdAt < endOfDay
            )
            return try db.scalar(query.count)
        } catch {
            print("获取今日完成数失败: \(error)")
            return 0
        }
    }

    // 获取总专注分钟数
    func getTotalFocusMinutes() -> Int {
        do {
            return try db.scalar(timerHistory.select(minutes.sum)) ?? 0
        } catch {
            print("获取总专注分钟数失败: \(error)")
            return 0
        }
    }
}

