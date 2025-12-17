//
//  Task.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var category: TaskCategory
    var priority: TaskPriority
    var deadline: Date?
    var completed: Bool
    var createdAt: Date
    var completedAt: Date?

    init(title: String, category: TaskCategory = .work, priority: TaskPriority = .medium, deadline: Date? = nil) {
        self.title = title
        self.category = category
        self.priority = priority
        self.deadline = deadline
        self.completed = false
        self.createdAt = Date()
    }

    // 标记为完成
    mutating func markAsCompleted() {
        completed = true
        completedAt = Date()
    }

    // 获取任务积分
    var points: Int {
        if !completed { return 0 }
        return priority == .high ? 20 : 10
    }

    // 获取优先级显示文本
    var priorityText: String {
        switch priority {
        case .high:
            return "高"
        case .medium:
            return "中"
        case .low:
            return "低"
        }
    }

    // 获取分类显示文本
    var categoryText: String {
        return category.displayName
    }

    // 检查是否即将到期（24小时内）
    var isDueSoon: Bool {
        guard let deadline = deadline else { return false }
        let timeInterval = deadline.timeIntervalSinceNow
        return timeInterval > 0 && timeInterval <= 24 * 60 * 60
    }

    // 检查是否已过期
    var isOverdue: Bool {
        guard let deadline = deadline else { return false }
        return deadline < Date() && !completed
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "工作项目"
    case programming = "编程学习"
    case reading = "阅读"
    case exercise = "运动"
    case chores = "家务"
    case other = "其他"

    var displayName: String {
        return rawValue
    }

    var icon: String {
        switch self {
        case .work:
            return "briefcase"
        case .programming:
            return "laptopcomputer"
        case .reading:
            return "book"
        case .exercise:
            return "figure.run"
        case .chores:
            return "house"
        case .other:
            return "star"
        }
    }
}

enum TaskPriority: Int, CaseIterable, Codable {
    case low = 1
    case medium = 2
    case high = 3

    var displayName: String {
        switch self {
        case .low:
            return "低"
        case .medium:
            return "中"
        case .high:
            return "高"
        }
    }

    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
}