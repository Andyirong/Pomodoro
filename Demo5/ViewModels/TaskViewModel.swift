//
//  TaskViewModel.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var selectedCategory: TaskCategory? = nil
    @Published var showCompletedOnly: Bool = false
    @Published var searchText: String = ""

    private var taskDAO: TaskDAO?
    private var statsDAO: StatsDAO?

    init() {
        // 初始化 DAO
        do {
            taskDAO = try TaskDAO()
            statsDAO = try StatsDAO()
        } catch {
            print("初始化数据库失败: \(error)")
        }

        loadTasks()
    }

    // MARK: - 任务管理

    func addTask(_ task: Task) {
        do {
            _ = try taskDAO?.insertTask(task)
            loadTasks()
        } catch {
            print("添加任务失败: \(error)")
        }
    }

    func updateTask(_ task: Task) {
        let success = taskDAO?.updateTask(task) ?? false
        if success {
            loadTasks()
        }
    }

    func deleteTask(_ task: Task) {
        guard let taskId = task.dbId else { return }
        let success = taskDAO?.deleteTask(id: taskId) ?? false
        if success {
            loadTasks()
        }
    }

    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        if updatedTask.completed {
            // 如果是已完成，取消完成状态
            updatedTask.completed = false
            updatedTask.completedAt = nil
        } else {
            // 标记为完成
            updatedTask.markAsCompleted()

            // 更新统计数据
            let todayStats = statsDAO?.getTodayStats() ?? (totalMinutes: 0, completedTomatoes: 0, tasksDone: 0)
            do {
                try statsDAO?.saveDailyStats(
                    date: Date(),
                    totalMinutes: todayStats.totalMinutes,
                    completedTomatoes: todayStats.completedTomatoes,
                    tasksDone: todayStats.tasksDone + 1
                )
            } catch {
                print("保存统计数据失败: \(error)")
            }

            // 触发通知
            NotificationCenter.default.post(name: .taskCompleted, object: updatedTask)
        }

        updateTask(updatedTask)
    }

    // MARK: - 数据加载

    func loadTasks() {
        tasks = taskDAO?.getAllTasks() ?? []
        applyFilters()
    }

    func loadActiveTasks() {
        tasks = taskDAO?.getTasksByCompleted(false) ?? []
        applyFilters()
    }

    func loadCompletedTasks() {
        tasks = taskDAO?.getTasksByCompleted(true) ?? []
        applyFilters()
    }

    func loadTodayTasks() {
        tasks = taskDAO?.getTodayTasks() ?? []
        applyFilters()
    }

    func loadTasksByCategory(_ category: TaskCategory) {
        tasks = taskDAO?.getTasksByCategory(category) ?? []
        applyFilters()
    }

    // MARK: - 过滤和搜索

    func applyFilters() {
        filteredTasks = tasks

        // 按分类过滤
        if let category = selectedCategory {
            filteredTasks = filteredTasks.filter { $0.category == category }
        }

        // 按完成状态过滤
        if showCompletedOnly {
            filteredTasks = filteredTasks.filter { $0.completed }
        }

        // 按搜索文本过滤
        if !searchText.isEmpty {
            filteredTasks = filteredTasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 排序：未完成的在前，按优先级和创建时间排序
        filteredTasks.sort { task1, task2 in
            if task1.completed != task2.completed {
                return !task1.completed
            }

            if task1.priority.rawValue != task2.priority.rawValue {
                return task1.priority.rawValue > task2.priority.rawValue
            }

            if let deadline1 = task1.deadline, let deadline2 = task2.deadline {
                return deadline1 < deadline2
            }

            return task1.createdAt < task2.createdAt
        }
    }

    func filterByCategory(_ category: TaskCategory?) {
        selectedCategory = category
        applyFilters()
    }

    func filterByCompletionStatus(_ completed: Bool) {
        showCompletedOnly = completed
        applyFilters()
    }

    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }

    // MARK: - 统计信息

    func getTaskStats() -> (total: Int, completed: Int, pending: Int) {
        return taskDAO?.getTaskStats() ?? (total: 0, completed: 0, pending: 0)
    }

    func getTasksByCategory() -> [TaskCategory: [Task]] {
        var categorizedTasks: [TaskCategory: [Task]] = [:]

        for category in TaskCategory.allCases {
            categorizedTasks[category] = tasks.filter { $0.category == category }
        }

        return categorizedTasks
    }

    func getHighPriorityTasks() -> [Task] {
        return tasks.filter { $0.priority == .high && !$0.completed }
    }

    func getOverdueTasks() -> [Task] {
        return tasks.filter { $0.isOverdue }
    }

    func getDueSoonTasks() -> [Task] {
        return tasks.filter { $0.isDueSoon && !$0.completed }
    }

    // MARK: - 快捷操作

    func quickAddTask(title: String, category: TaskCategory = .work) {
        let task = Task(title: title, category: category)
        addTask(task)
    }

    func completeAllTasks() {
        for var task in filteredTasks where !task.completed {
            task.markAsCompleted()
            updateTask(task)
        }
    }

    func deleteAllCompleted() {
        let completedTasks = tasks.filter { $0.completed }
        for task in completedTasks {
            deleteTask(task)
        }
    }

    // MARK: - 计算属性

    var activeTasksCount: Int {
        return tasks.filter { !$0.completed }.count
    }

    var completedTasksCount: Int {
        return tasks.filter { $0.completed }.count
    }

    var todayTasksCount: Int {
        return taskDAO?.getTodayTasks().count ?? 0
    }

    var completionRate: Double {
        let stats = getTaskStats()
        return stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0.0
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let taskCompleted = Notification.Name("taskCompleted")
}