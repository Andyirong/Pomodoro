//
//  TaskDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite

class TaskDAO {
    private let db: Connection

    // 表和列定义
    private let tasks = Table("tasks")
    private let id = Expression<Int64>("id")
    private let title = Expression<String>("title")
    private let category = Expression<String>("category")
    private let priority = Expression<Int>("priority")
    private let deadline = Expression<Date?>("deadline")
    private let completed = Expression<Int>("completed")
    private let createdAt = Expression<Date>("created_at")
    private let completedAt = Expression<Date?>("completed_at")

    init() throws {
        guard let database = DatabaseManager.shared.getDatabase() else {
            throw DatabaseError.notConnected
        }
        db = database
    }

    // 插入新任务
    func insertTask(_ task: Task) throws -> Int64 {
        let insert = tasks.insert(
            title <- task.title,
            category <- task.category.rawValue,
            priority <- task.priority.rawValue,
            deadline <- task.deadline,
            completed <- task.completed ? 1 : 0,
            createdAt <- task.createdAt,
            completedAt <- task.completedAt
        )
        return try db.run(insert)
    }

    // 获取所有任务
    func getAllTasks() -> [Task] {
        do {
            let query = tasks.order(createdAt.desc)
            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("获取所有任务失败: \(error)")
            return []
        }
    }

    // 根据完成状态获取任务
    func getTasksByCompleted(_ isCompleted: Bool) -> [Task] {
        do {
            let query = tasks
                .filter(self.completed == (isCompleted ? 1 : 0))
                .order(createdAt.desc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("根据完成状态获取任务失败: \(error)")
            return []
        }
    }

    // 根据分类获取任务
    func getTasksByCategory(_ taskCategory: TaskCategory) -> [Task] {
        do {
            let query = tasks
                .filter(self.category == taskCategory.rawValue)
                .order(createdAt.desc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("根据分类获取任务失败: \(error)")
            return []
        }
    }

    // 获取今日到期的任务
    func getTodayTasks() -> [Task] {
        do {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let query = tasks
                .filter(self.deadline >= startOfDay && self.deadline < endOfDay)
                .order(self.priority.desc, self.createdAt.asc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("获取今日到期任务失败: \(error)")
            return []
        }
    }

    // 更新任务
    func updateTask(_ task: Task) -> Bool {
        do {
            guard let taskId = task.dbId else {
                print("任务ID不能为空")
                return false
            }

            let update = tasks
                .filter(self.id == taskId)
                .update(
                    self.title <- task.title,
                    self.category <- task.category.rawValue,
                    self.priority <- task.priority.rawValue,
                    self.deadline <- task.deadline,
                    self.completed <- task.completed ? 1 : 0,
                    self.completedAt <- task.completedAt
                )

            let changes = try db.run(update)
            return changes > 0
        } catch {
            print("更新任务失败: \(error)")
            return false
        }
    }

    // 删除任务
    func deleteTask(id: Int64) -> Bool {
        do {
            let deleteQuery = tasks.filter(self.id == id)
            let changes = try db.run(deleteQuery.delete())
            return changes > 0
        } catch {
            print("删除任务失败: \(error)")
            return false
        }
    }

    // 获取任务统计
    func getTaskStats() -> (total: Int, completed: Int, pending: Int) {
        do {
            let totalCount = try db.scalar(tasks.count)
            let completedCount = try db.scalar(tasks.filter(completed == 1).count)

            return (total: totalCount, completed: completedCount, pending: totalCount - completedCount)
        } catch {
            print("获取任务统计失败: \(error)")
            return (total: 0, completed: 0, pending: 0)
        }
    }

    // 获取高优先级任务
    func getHighPriorityTasks() -> [Task] {
        do {
            let query = tasks
                .filter(self.priority == TaskPriority.high.rawValue && self.completed == 0)
                .order(self.createdAt.asc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("获取高优先级任务失败: \(error)")
            return []
        }
    }

    // 获取过期任务
    func getOverdueTasks() -> [Task] {
        do {
            let query = tasks
                .filter(self.deadline < Date() && self.completed == 0)
                .order(self.deadline.asc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("获取过期任务失败: \(error)")
            return []
        }
    }

    // 获取即将到期任务（24小时内）
    func getDueSoonTasks() -> [Task] {
        do {
            let now = Date()
            let twentyFourHoursLater = Calendar.current.date(byAdding: .hour, value: 24, to: now)!
            let twentyFourHoursBefore = Calendar.current.date(byAdding: .hour, value: -24, to: now)!

            let query = tasks
                .filter(
                    self.deadline >= twentyFourHoursBefore && self.deadline <= twentyFourHoursLater && self.completed == 0
                )
                .order(self.deadline.asc)

            return try db.prepare(query).map { row in
                let categoryString = row[self.category]
                let category = TaskCategory(rawValue: categoryString) ?? .other

                let priorityValue = row[self.priority]
                let priority = TaskPriority(rawValue: priorityValue) ?? .medium

                let completedValue = row[self.completed]
                return Task(
                    dbId: row[self.id],
                    title: row[self.title],
                    category: category,
                    priority: priority,
                    deadline: row[self.deadline],
                    completed: completedValue != 0,
                    createdAt: row[self.createdAt],
                    completedAt: row[self.completedAt]
                )
            }
        } catch {
            print("获取即将到期任务失败: \(error)")
            return []
        }
    }
}

