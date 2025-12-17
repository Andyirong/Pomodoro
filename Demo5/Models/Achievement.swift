//
//  Achievement.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: Int
    var name: String
    var description: String
    var unlockedAt: Date?
    var pointsRequired: Int
    var pointsAwarded: Int
    var isUnlocked: Bool {
        return unlockedAt != nil
    }

    // 预定义的成就列表
    static let predefinedAchievements: [Achievement] = [
        Achievement(id: 1, name: "初学者", description: "完成第一个番茄钟", pointsRequired: 1, pointsAwarded: 10),
        Achievement(id: 2, name: "专注入门", description: "累计完成10个番茄钟", pointsRequired: 10, pointsAwarded: 50),
        Achievement(id: 3, name: "专注达人", description: "累计完成50个番茄钟", pointsRequired: 50, pointsAwarded: 200),
        Achievement(id: 4, name: "专注大师", description: "累计完成100个番茄钟", pointsRequired: 100, pointsAwarded: 500),
        Achievement(id: 5, name: "连续三天", description: "连续3天使用番茄钟", pointsRequired: 0, pointsAwarded: 50),
        Achievement(id: 6, name: "连续一周", description: "连续7天使用番茄钟", pointsRequired: 0, pointsAwarded: 100),
        Achievement(id: 7, name: "连续一月", description: "连续30天使用番茄钟", pointsRequired: 0, pointsAwarded: 500),
        Achievement(id: 8, name: "积分新手", description: "累计获得100积分", pointsRequired: 100, pointsAwarded: 20),
        Achievement(id: 9, name: "积分高手", description: "累计获得500积分", pointsRequired: 500, pointsAwarded: 100),
        Achievement(id: 10, name: "积分大师", description: "累计获得1000积分", pointsRequired: 1000, pointsAwarded: 200),
        Achievement(id: 11, name: "任务完成者", description: "完成10个任务", pointsRequired: 10, pointsAwarded: 50),
        Achievement(id: 12, name: "高效工作者", description: "完成50个任务", pointsRequired: 50, pointsAwarded: 200),
        Achievement(id: 13, name: "马拉松选手", description: "完成一次90分钟番茄钟", pointsRequired: 1, pointsAwarded: 50),
        Achievement(id: 14, name: "早起鸟儿", description: "早上8点前完成番茄钟", pointsRequired: 1, pointsAwarded: 30),
        Achievement(id: 15, name: "夜猫子", description: "晚上10点后完成番茄钟", pointsRequired: 1, pointsAwarded: 30)
    ]

    var icon: String {
        switch id {
        case 1:
            return "star.fill"
        case 2...4:
            return "flame.fill"
        case 5...7:
            return "calendar.badge.clock"
        case 8...10:
            return "trophy.fill"
        case 11...12:
            return "checkmark.circle.fill"
        case 13:
            return "clock.fill"
        case 14:
            return "sunrise.fill"
        case 15:
            return "moon.fill"
        default:
            return "star.fill"
        }
    }

    var unlockColor: String {
        if isUnlocked {
            return "yellow"
        } else {
            return "gray"
        }
    }
}