# SQLite.swift 集成方案

**版本：1.0**
**日期：2025-12-17**
**目标：替换原生SQLite3 API，使用SQLite.swift库**

## 📋 方案概述

SQLite.swift是一个纯Swift编写的SQLite封装库，提供了类型安全的SQL操作，比原生C API更加易用和安全。

## 🎯 集成优势

1. **类型安全** - 编译时检查SQL语句
2. **Swift原生API** - 无需处理C指针和内存管理
3. **链式调用** - 更直观的查询语法
4. **错误处理** - 完整的Swift错误处理机制
5. **代码简洁** - 大幅减少样板代码

## 🔧 集成步骤

### 第一步：添加依赖包

#### 方法1：Swift Package Manager（推荐）

1. 打开Xcode项目
2. 选择 `File` → `Add Package Dependencies...`
3. 输入URL：`https://github.com/stephencelis/SQLite.swift`
4. 选择版本：`0.14.1` 或最新稳定版
5. 点击 `Add Package`

#### 方法2：CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'SQLite.swift', '~> 0.14.1'
```

然后运行：
```bash
pod install
```

#### 方法3：Carthage

在 `Cartfile` 中添加：

```
github "stephencelis/SQLite.swift" ~> 0.14.1
```

然后运行：
```bash
carthage update --platform iOS
```

### 第二步：更新项目设置

1. 移除对原生`libsqlite3.tbd`的链接（SQLite.swift已包含）
2. 更新import语句：
   ```swift
   // 移除
   import SQLite3

   // 替换为
   import SQLite
   ```

## 🔄 代码迁移计划

### 1. DatabaseManager.swift 重构

#### 原生版本 → SQLite.swift版本

```swift
// 原生版本
import SQLite3
class DatabaseManager {
    private var db: OpaquePointer?

    func openDatabase() -> Bool {
        // C API调用
    }
}

// SQLite.swift版本
import SQLite
class DatabaseManager {
    private var db: Connection?

    func openDatabase() throws {
        db = try Connection(databasePath)
    }
}
```

### 2. 数据访问层重构

#### TimerDAO.swift 重构示例

**原生版本：**
```swift
let sql = "SELECT * FROM timer_history ORDER BY created_at DESC LIMIT ?;"
if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
    sqlite3_bind_int(statement, 1, Int32(limit))
    while sqlite3_step(statement) == SQLITE_ROW {
        let minutes = Int(sqlite3_column_int(statement, 1))
        // ...
    }
}
```

**SQLite.swift版本：**
```swift
let query = timerHistoryTable
    .order(created_at.desc)
    .limit(limit)

for row in try db.prepare(query) {
    let minutes = row[minutesCol]
    // ...
}
```

### 3. 数据模型适配

#### 使用Codable协议

```swift
struct TimerSettings: Codable {
    let id: Int64?
    let minutes: Int
    let seconds: Int
    let note: String
    let createdAt: Date

    // 定义表达式
    static let table = Table("timer_history")
    static let id = Expression<Int64>("id")
    static let minutes = Expression<Int>("minutes")
    static let seconds = Expression<Int>("seconds")
    static let note = Expression<String>("note")
    static let createdAt = Expression<Date>("created_at")
}
```

## 📝 详细重构计划

### 阶段1：设置和基础迁移（1小时）

1. ✅ 添加SQLite.swift依赖
2. ✅ 更新imports
3. ✅ 重构DatabaseManager基础结构
4. ✅ 创建表定义

### 阶段2：DAO层重构（2-3小时）

1. 🔄 TimerDAO.swift重构
2. 🔄 TaskDAO.swift重构
3. 🔄 StatsDAO.swift重构

### 阶段3：测试和验证（1小时）

1. 🔲 数据库操作测试
2. 🔲 性能对比测试
3. 🔲 错误处理验证

## 🎨 重构后的代码示例

### 新的DatabaseManager.swift

```swift
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private init() {}

    func openDatabase() throws {
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PomodoroDatabase.sqlite")

        db = try Connection(fileURL.path)

        // 启用外键约束
        db?.execute("PRAGMA foreign_keys = ON")

        try createTables()
    }

    private func createTables() throws {
        try db?.run(TimerSettings.createTable)
        try db?.run(Task.createTable)
        try db?.run(Achievement.createTable)
        try db?.run(UserStats.createTable)
        try db?.run(Statistics.createTable)
    }

    func getDatabase() -> Connection {
        return db!
    }
}
```

### 新的TimerSettings.swift

```swift
import Foundation
import SQLite

struct TimerSettings: Codable {
    let id: Int64?
    var minutes: Int
    var seconds: Int
    var note: String
    var createdAt: Date
    var usageCount: Int

    // SQLite表达式定义
    static let table = Table("timer_history")
    static let id = Expression<Int64>("id")
    static let minutes = Expression<Int>("minutes")
    static let seconds = Expression<Int>("seconds")
    static let note = Expression<String>("note")
    static let createdAt = Expression<Date>("created_at")
    static let usageCount = Expression<Int>("usage_count")

    // 创建表
    static func createTable(_ db: Connection) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(minutes)
            t.column(seconds)
            t.column(note)
            t.column(createdAt, defaultValue: Date())
            t.column(usageCount, defaultValue: 1)
        })
    }
}
```

### 新的TimerDAO.swift

```swift
import Foundation
import SQLite

class TimerDAO {
    private let db: Connection

    init() throws {
        db = DatabaseManager.shared.getDatabase()
    }

    // 插入新记录
    func insert(_ settings: TimerSettings) throws -> Int64 {
        let insert = TimerSettings.table.insert(
            TimerSettings.minutes <- settings.minutes,
            TimerSettings.seconds <- settings.seconds,
            TimerSettings.note <- settings.note,
            TimerSettings.usageCount <- settings.usageCount
        )
        return try db.run(insert)
    }

    // 获取最近的记录
    func getRecent(limit: Int = 10) throws -> [TimerSettings] {
        let query = TimerSettings.table
            .order(TimerSettings.createdAt.desc)
            .limit(limit)

        return try db.prepare(query).map { row in
            TimerSettings(
                id: row[TimerSettings.id],
                minutes: row[TimerSettings.minutes],
                seconds: row[TimerSettings.seconds],
                note: row[TimerSettings.note],
                createdAt: row[TimerSettings.createdAt],
                usageCount: row[TimerSettings.usageCount]
            )
        }
    }

    // 更新使用次数
    func updateUsageCount(minutes: Int, seconds: Int) throws {
        let update = TimerSettings.table
            .filter(TimerSettings.minutes == minutes && TimerSettings.seconds == seconds)
            .update(
                TimerSettings.usageCount += 1,
                TimerSettings.createdAt <- Date()
            )
        try db.run(update)
    }
}
```

## 📊 性能和优势对比

| 特性 | 原生SQLite3 | SQLite.swift |
|------|-------------|--------------|
| 代码量 | 多 | 少 |
| 类型安全 | ❌ | ✅ |
| 错误处理 | C错误码 | Swift异常 |
| SQL注入风险 | 高 | 低 |
| 内存管理 | 手动 | 自动 |
| 可读性 | 低 | 高 |
| 调试难度 | 高 | 低 |

## ⚠️ 迁移注意事项

1. **错误处理变更**：从返回Bool改为throws
2. **异步操作**：考虑添加async/await支持
3. **类型映射**：SQLite类型到Swift类型的转换
4. **线程安全**：确保数据库操作的线程安全
5. **迁移数据**：考虑现有用户数据的迁移方案

## 🚀 实施建议

1. **分阶段实施**：先完成DatabaseManager，再逐个重构DAO
2. **保留旧代码**：在新代码稳定前，暂时保留原版本
3. **充分测试**：重点测试边界情况和错误处理
4. **性能监控**：关注数据库操作的性能变化

## 📋 检查清单

- [ ] 添加SQLite.swift依赖
- [ ] 更新所有import语句
- [ ] 重构DatabaseManager
- [ ] 更新数据模型定义
- [ ] 重构所有DAO类
- [ ] 更新错误处理逻辑
- [ ] 测试所有数据库操作
- [ ] 验证性能无明显下降
- [ ] 清理旧的SQLite3引用

---

**预计完成时间：4-5小时**
**风险评估：低**
**推荐优先级：高**