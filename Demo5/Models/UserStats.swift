//
//  UserStats.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation

struct UserStats: Codable {
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalTomatoesCompleted: Int
    var totalTasksCompleted: Int
    var totalFocusMinutes: Int
    var lastUsedDate: Date?

    init() {
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalTomatoesCompleted = 0
        self.totalTasksCompleted = 0
        self.totalFocusMinutes = 0
        self.lastUsedDate = nil
    }

    // 更新连续使用天数
    mutating func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastUsedDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 1 {
                // 连续使用
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
                // 连续奖励
                if currentStreak == 3 {
                    totalPoints += 50
                } else if currentStreak == 7 {
                    totalPoints += 100
                } else if currentStreak == 30 {
                    totalPoints += 500
                }
            } else if daysDiff > 1 {
                // 中断了连续使用
                currentStreak = 1
            }
            // daysDiff == 0 表示今天已经使用过了，不更新
        } else {
            // 第一次使用
            currentStreak = 1
            longestStreak = 1
        }

        lastUsedDate = today
    }

    // 添加番茄钟完成记录
    mutating func addTomatoCompletion(minutes: Int, seconds: Int) {
        totalTomatoesCompleted += 1
        totalFocusMinutes += (minutes * 60 + seconds) / 60

        // 根据时长添加积分
        let totalSeconds = minutes * 60 + seconds
        let points: Int
        switch totalSeconds {
        case 0..<300:  // 5分钟以下
            points = 0
        case 300..<900:  // 5-15分钟
            points = 5
        case 900..<1500:  // 15-25分钟
            points = 10
        case 1500..<2700:  // 25-45分钟
            points = 15
        case 2700..<3600:  // 45-60分钟
            points = 20
        case 3600..<5400:  // 60-90分钟
            points = 25
        default:  // 90分钟以上
            points = 30
        }
        totalPoints += points

        updateStreak()
    }

    // 添加任务完成记录
    mutating func addTaskCompletion(priority: TaskPriority) {
        totalTasksCompleted += 1
        let points = priority == .high ? 20 : 10
        totalPoints += points
        updateStreak()
    }

    // 获取当前等级
    var level: Int {
        switch totalPoints {
        case 0..<50:
            return 1
        case 50..<150:
            return 2
        case 150..<300:
            return 3
        case 300..<500:
            return 4
        case 500..<1000:
            return 5
        case 1000..<2000:
            return 6
        case 2000..<5000:
            return 7
        default:
            return 8
        }
    }

    // 获取等级名称
    var levelName: String {
        switch level {
        case 1:
            return "新手入门"
        case 2:
            return "专注学徒"
        case 3:
            return "专注能手"
        case 4:
            return "专注达人"
        case 5:
            return "专注大师"
        case 6:
            return "时间掌控者"
        case 7:
            return "效率王者"
        default:
            return "传奇大师"
        }
    }

    // 获取下一等级所需积分
    var nextLevelPoints: Int {
        switch level {
        case 1:
            return 50
        case 2:
            return 150
        case 3:
            return 300
        case 4:
            return 500
        case 5:
            return 1000
        case 6:
            return 2000
        case 7:
            return 5000
        default:
            return totalPoints
        }
    }

    // 获取当前等级进度
    var levelProgress: Double {
        if level >= 8 { return 1.0 }

        let previousLevelPoints: Int
        switch level {
        case 1:
            previousLevelPoints = 0
        case 2:
            previousLevelPoints = 50
        case 3:
            previousLevelPoints = 150
        case 4:
            previousLevelPoints = 300
        case 5:
            previousLevelPoints = 500
        case 6:
            previousLevelPoints = 1000
        case 7:
            previousLevelPoints = 2000
        default:
            previousLevelPoints = 0
        }

        let currentLevelRange = nextLevelPoints - previousLevelPoints
        let currentProgress = totalPoints - previousLevelPoints

        return Double(currentProgress) / Double(currentLevelRange)
    }
}