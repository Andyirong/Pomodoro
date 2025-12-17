//
//  TaskDAO.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite3

class TaskDAO {
    private let db: OpaquePointer?

    init() {
        db = DatabaseManager.shared.getDatabase()
    }

    // 插入新任务
    func insertTask(_ task: Task) -> Bool {
        var statement: OpaquePointer?
        let sql = """
            INSERT INTO tasks (title, category, priority, deadline, completed, created_at)
            VALUES (?, ?, ?, ?, ?, ?);
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, task.title, -1, nil)
            sqlite3_bind_text(statement, 2, task.category.rawValue, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(task.priority.rawValue))

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            if let deadline = task.deadline {
                let deadlineString = formatter.string(from: deadline)
                sqlite3_bind_text(statement, 4, deadlineString, -1, nil)
            } else {
                sqlite3_bind_null(statement, 4)
            }

            sqlite3_bind_int(statement, 5, task.completed ? 1 : 0)

            let createdString = formatter.string(from: task.createdAt)
            sqlite3_bind_text(statement, 6, createdString, -1, nil)

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        sqlite3_finalize(statement)
        return false
    }

    // 获取所有任务
    func getAllTasks() -> [Task] {
        return getTasksWithSQL("SELECT * FROM tasks ORDER BY created_at DESC;")
    }

    // 根据完成状态获取任务
    func getTasksByCompleted(_ completed: Bool) -> [Task] {
        let sql = "SELECT * FROM tasks WHERE completed = ? ORDER BY created_at DESC;"
        return getTasksWithSQL(sql, bind: { statement in
            sqlite3_bind_int(statement, 1, completed ? 1 : 0)
        })
    }

    // 根据分类获取任务
    func getTasksByCategory(_ category: TaskCategory) -> [Task] {
        let sql = "SELECT * FROM tasks WHERE category = ? ORDER BY created_at DESC;"
        return getTasksWithSQL(sql, bind: { statement in
            sqlite3_bind_text(statement, 1, category.rawValue, -1, nil)
        })
    }

    // 获取今日到期的任务
    func getTodayTasks() -> [Task] {
        let sql = """
            SELECT * FROM tasks
            WHERE DATE(deadline) = DATE('now')
            ORDER BY priority DESC, created_at ASC;
        """
        return getTasksWithSQL(sql)
    }

    // 更新任务
    func updateTask(_ task: Task) -> Bool {
        var statement: OpaquePointer?
        let sql = """
            UPDATE tasks
            SET title = ?, category = ?, priority = ?, deadline = ?, completed = ?
            WHERE id = ?;
        """

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, task.title, -1, nil)
            sqlite3_bind_text(statement, 2, task.category.rawValue, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(task.priority.rawValue))

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            if let deadline = task.deadline {
                let deadlineString = formatter.string(from: deadline)
                sqlite3_bind_text(statement, 4, deadlineString, -1, nil)
            } else {
                sqlite3_bind_null(statement, 4)
            }

            sqlite3_bind_int(statement, 5, task.completed ? 1 : 0)
            sqlite3_bind_int(statement, 6, Int32(truncating: task.id.uuidString.hashValue as NSNumber))

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        sqlite3_finalize(statement)
        return false
    }

    // 删除任务
    func deleteTask(id: UUID) -> Bool {
        var statement: OpaquePointer?
        let sql = "DELETE FROM tasks WHERE id = ?;"

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(truncating: id.uuidString.hashValue as NSNumber))

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        sqlite3_finalize(statement)
        return false
    }

    // 获取任务统计
    func getTaskStats() -> (total: Int, completed: Int, pending: Int) {
        var total = 0
        var completed = 0

        // 获取总数
        var statement: OpaquePointer?
        let totalSQL = "SELECT COUNT(*) FROM tasks;"
        if sqlite3_prepare_v2(db, totalSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                total = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        // 获取已完成数
        let completedSQL = "SELECT COUNT(*) FROM tasks WHERE completed = 1;"
        if sqlite3_prepare_v2(db, completedSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                completed = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        return (total: total, completed: completed, pending: total - completed)
    }

    // 通用查询方法
    private func getTasksWithSQL(_ sql: String, bind: ((OpaquePointer?) -> Void)? = nil) -> [Task] {
        var tasks: [Task] = []
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bind?(statement)

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)

                let titlePtr = sqlite3_column_text(statement, 1)
                let title = titlePtr != nil ? String(cString: titlePtr!) : ""

                let categoryPtr = sqlite3_column_text(statement, 2)
                let categoryString = categoryPtr != nil ? String(cString: categoryPtr!) : "工作项目"
                let category = TaskCategory(rawValue: categoryString) ?? .work

                let priority = TaskPriority(rawValue: Int(sqlite3_column_int(statement, 3))) ?? .medium

                let deadlinePtr = sqlite3_column_text(statement, 4)
                var deadline: Date?
                if deadlinePtr != nil {
                    let deadlineString = String(cString: deadlinePtr!)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    deadline = formatter.date(from: deadlineString)
                }

                let completed = sqlite3_column_int(statement, 5) == 1

                let createdAtPtr = sqlite3_column_text(statement, 6)
                let createdString = createdAtPtr != nil ? String(cString: createdAtPtr!) : ""
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let createdAt = formatter.date(from: createdString) ?? Date()

                var task = Task(title: title, category: category, priority: priority, deadline: deadline)
                task = Task(
                    title: title,
                    category: category,
                    priority: priority,
                    deadline: deadline
                )

                tasks.append(task)
            }
        }

        sqlite3_finalize(statement)
        return tasks
    }
}