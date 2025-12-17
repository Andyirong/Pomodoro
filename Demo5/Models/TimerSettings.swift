//
//  TimerSettings.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation

struct TimerSettings: Identifiable, Codable {
    let id = UUID()
    var minutes: Int
    var seconds: Int
    var note: String
    var createdAt: Date
    var usageCount: Int

    init(minutes: Int = 25, seconds: Int = 0, note: String = "") {
        self.minutes = minutes
        self.seconds = seconds
        self.note = note
        self.createdAt = Date()
        self.usageCount = 1
    }

    // 计算总秒数
    var totalSeconds: Int {
        return minutes * 60 + seconds
    }

    // 格式化显示时间
    var displayTime: String {
        let mins = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secs = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(mins):\(secs)"
    }

    // 获取积分
    var points: Int {
        switch totalSeconds {
        case 0..<300:  // 5分钟以下
            return 0
        case 300..<900:  // 5-15分钟
            return 5
        case 900..<1500:  // 15-25分钟
            return 10
        case 1500..<2700:  // 25-45分钟
            return 15
        case 2700..<3600:  // 45-60分钟
            return 20
        case 3600..<5400:  // 60-90分钟
            return 25
        default:  // 90分钟以上
            return 30
        }
    }
}