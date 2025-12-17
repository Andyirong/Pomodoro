# SQLite.swift 快速迁移指南

## 🚀 立即开始 - 只需3步

### 步骤1：添加依赖包

1. 打开Xcode项目 `Demo5.xcodeproj`
2. 点击 `File` → `Add Package Dependencies...`
3. 粘贴URL：`https://github.com/stephencelis/SQLite.swift`
4. 选择版本，点击 `Add Package`

### 步骤2：替换DatabaseManager.swift

用下面的代码替换 `Demo5/Database/DatabaseManager.swift`：

```swift
//
//  DatabaseManager.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private init() {}

    func openDatabase() -> Bool {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("PomodoroDatabase.sqlite")

            db = try Connection(fileURL.path)

            // 启用外键约束
            try db?.execute("PRAGMA foreign_keys = ON")

            try createTables()

            print("✅ 数据库连接成功")
            return true
        } catch {
            print("❌ 数据库打开失败: \(error)")
            return false
        }
    }

    private func createTables() throws {
        guard let db = db else { throw DatabaseError.notConnected }

        // 创建 timer_history 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS timer_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                minutes INTEGER NOT NULL,
                seconds INTEGER NOT NULL,
                note TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                usage_count INTEGER DEFAULT 1
            );
        """)

        // 创建 tasks 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                category TEXT,
                priority INTEGER DEFAULT 1,
                deadline DATETIME,
                completed INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
        """)

        // 创建 user_settings 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS user_settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                total_points INTEGER DEFAULT 0,
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0
            );
        """)

        // 创建 achievements 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS achievements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                unlocked_at DATETIME,
                points_required INTEGER,
                points_awarded INTEGER
            );
        """)

        // 创建 statistics 表
        try db.run("""
            CREATE TABLE IF NOT EXISTS statistics (
                date DATE PRIMARY KEY,
                total_minutes INTEGER DEFAULT 0,
                completed_tomatoes INTEGER DEFAULT 0,
                tasks_done INTEGER DEFAULT 0
            );
        """)

        // 初始化默认设置
        initializeDefaultSettings()
    }

    private func initializeDefaultSettings() {
        guard let db = db else { return }

        do {
            let count = try db.scalar("SELECT COUNT(*) FROM user_settings;")

            if count == 0 {
                let defaultSettings = [
                    ("total_points", "0"),
                    ("current_streak", "0"),
                    ("longest_streak", "0"),
                    ("sound_enabled", "true"),
                    ("vibration_enabled", "true"),
                    ("default_minutes", "25"),
                    ("default_seconds", "0")
                ]

                for (key, value) in defaultSettings {
                    try db.run("INSERT INTO user_settings (key, value) VALUES (?, ?);", key, value)
                }
                print("✅ 默认设置初始化完成")
            }
        } catch {
            print("⚠️ 设置初始化失败: \(error)")
        }
    }

    func getDatabase() -> Connection? {
        return db
    }
}

enum DatabaseError: Error {
    case notConnected
    case operationFailed(String)
}
```

### 步骤3：更新其他文件的imports

在所有数据库相关文件顶部，将：
```swift
import SQLite3
```

替换为：
```swift
import SQLite
```

## 📝 快速验证

1. **编译测试**：确保项目能正常编译
2. **功能测试**：运行应用，确保倒计时功能正常
3. **数据库测试**：检查是否能正常创建数据库文件

## 🔧 下一步

完成基础迁移后，可以选择：
1. **使用简化的DAO** - 继续使用现有DAO结构，只需更新API调用
2. **使用类型安全的Codable模式** - 获得更好的类型安全

## 💡 提示

- SQLite.swift会自动管理内存，无需手动释放
- 错误信息更加清晰，便于调试
- SQL语句可以使用Swift字符串插值，更安全

---

**预计时间：30分钟**
**难度：简单**
**收益：显著提升代码质量和安全性**