# 番茄闹钟App开发计划

**文档编号：DEV-PLAN-001**
**版本：1.0**
**创建日期：2025-12-17**

## 📋 总览

基于需求文档PD-001，将开发工作分为4个阶段，预计完成时间：2-3周

---

## 🏗️ 第一阶段：基础架构（3-4天）

### Day 1: 数据库层
- [ ] **任务1.1**: 创建SQLite数据库管理器
  - `DatabaseManager.swift` - 单例模式管理数据库连接
  - 实现数据库初始化和版本管理

- [ ] **任务1.2**: 创建数据模型
  - `TimerSettings.swift` - 倒计时设置模型
  - `Task.swift` - 任务模型
  - `Achievement.swift` - 成就模型
  - `UserStats.swift` - 用户统计模型

- [ ] **任务1.3**: 创建DAO层
  - `TimerDAO.swift` - 倒计时历史数据访问
  - `TaskDAO.swift` - 任务数据访问
  - `StatsDAO.swift` - 统计数据访问

### Day 2: 核心ViewModel
- [ ] **任务1.4**: 实现`TimerViewModel`
  - 倒计时逻辑（分钟、秒数）
  - 开始/暂停/重置功能
  - 进度计算
  - 历史记录管理（保留10条）

- [ ] **任务1.5**: 实现`TaskViewModel`
  - 任务CRUD操作
  - 分类管理
  - 优先级处理

### Day 3: 基础UI框架
- [ ] **任务1.6**: 创建主题系统
  - `Color+Extensions.swift` - 定义粉色系颜色
  - `ThemeStyles.swift` - 统一的UI样式

- [ ] **任务1.7**: 重构现有UI
  - 将TimerView适配粉色主题
  - 创建通用UI组件

### Day 4: 集成测试
- [ ] **任务1.8**: 第一阶段功能联调
  - 数据持久化测试
  - 基础倒计时功能测试

---

## 🎨 第二阶段：核心功能实现（4-5天）

### Day 5: Q版助手角色
- [ ] **任务2.1**: 创建卡通助手视图
  - `AssistantCharacterView.swift` - Q版小萝莉角色
  - 实现不同状态表情（空闲/专注/暂停/完成）
  - 眨眼和呼吸动画

### Day 6: 交互功能
- [ ] **任务2.2**: 实现滑动选择时间
  - 添加手势识别器
  - 上下滑动调整分钟数
  - 触觉反馈

- [ ] **任务2.3**: 实现长按停止功能
  - 3秒长按检测
  - 圆形进度条动画
  - 振动反馈集成

### Day 7-8: 任务管理系统
- [ ] **任务2.4**: 创建任务管理界面
  - `TaskListView.swift` - 任务列表
  - `AddTaskView.swift` - 添加任务
  - `TaskCategoryView.swift` - 分类选择

- [ ] **任务2.5**: 任务统计功能
  - 完成率计算
  - 分类统计
  - 时间分析

### Day 9: 白噪音功能
- [ ] **任务2.6**: 集成白噪音
  - 准备音频文件（雨声、森林等）
  - `WhiteNoiseManager.swift` - 音频播放管理
  - 定时关闭功能

---

## 🌟 第三阶段：高级功能（3-4天）

### Day 10: 积分系统
- [ ] **任务3.1**: 实现积分计算
  - 积分规则实现
  - 积分获取动画
  - 连续打卡计算

- [ ] **任务3.2**: 创建积分显示界面
  - `PointsView.swift` - 积分展示
  - `StreakView.swift` - 连续天数

### Day 11: 成就系统
- [ ] **任务3.3**: 成就系统实现
  - `AchievementManager.swift` - 成就逻辑
  - `AchievementView.swift` - 成就展示
  - 成就解锁动画

### Day 12: 休息提醒
- [ ] **任务3.4**: 休息提醒功能
  - 定时提醒逻辑
  - 眼睛保健操指导界面
  - 伸展运动建议

### Day 13: 音效系统
- [ ] **任务3.5**: 集成可爱音效
  - 准备音效文件
  - `SoundManager.swift` - 音效播放管理
  - 按钮点击音效
  - 完成提醒音效

---

## ✨ 第四阶段：优化和完善（2-3天）

### Day 14: 动画优化
- [ ] **任务4.1**: Q弹动画实现
  - 按钮点击动画
  - 页面转场动画
  - 积分获得动画

- [ ] **任务4.2**: 性能优化
  - 内存优化
  - 动画流畅度优化
  - 数据库查询优化

### Day 15: UI美化
- [ ] **任务4.3**: 界面细节打磨
  - 调整配色和布局
  - 添加更多装饰元素
  - 适配不同屏幕尺寸

### Day 16: 测试和修复
- [ ] **任务4.4**: 全面测试
  - 功能测试
  - 边界情况测试
  - Bug修复

---

## 📊 开发资源分配

### 核心文件结构
```
Demo5/
├── Models/
│   ├── TimerSettings.swift      ✅ 已存在
│   ├── Task.swift              ✅ 已存在
│   ├── Achievement.swift       待创建
│   └── UserStats.swift         待创建
├── ViewModels/
│   ├── TimerViewModel.swift    ✅ 已存在
│   ├── ItemViewModel.swift     ✅ 已存在
│   └── TaskViewModel.swift     待创建
├── Views/
│   ├── TimerView.swift         ✅ 已存在
│   ├── AssistantCharacterView.swift  待创建
│   ├── TaskListView.swift      待创建
│   └── PointsView.swift        待创建
├── Database/
│   ├── DatabaseManager.swift   ✅ 已存在
│   ├── TimerDAO.swift          待创建
│   └── TaskDAO.swift           待创建
└── Utils/
    ├── SoundManager.swift      待创建
    ├── ThemeStyles.swift       待创建
    └── WhiteNoiseManager.swift 待创建
```

### 开发优先级
1. **高优先级**：数据库、核心倒计时功能、UI框架
2. **中优先级**：助手角色、任务管理、交互功能
3. **低优先级**：音效、动画、美化效果

---

## 🎯 里程碑

- **Week 1 结束**：完成基础架构，App可运行基本倒计时
- **Week 2 结束**：完成所有核心功能，UI基本成型
- **Week 3 结束**：完成所有功能，App达到可发布状态

---

## ⚠️ 风险提示

1. **技术风险**
   - SQLite数据同步可能出现冲突
   - 复杂动画可能影响性能
   - 音频播放可能受系统限制

2. **时间风险**
   - Q版角色设计比预期复杂
   - 音效资源准备耗时
   - 测试阶段可能发现更多问题

3. **建议缓冲**
   - 每个阶段预留1天缓冲时间
   - 优先保证核心功能完成
   - 可选功能视时间情况决定是否实现

---

## 📝 每日检查清单

- [ ] 代码提交到Git
- [ ] 更新任务进度
- [ ] 记录遇到的问题
- [ ] 规划次日任务

---

**开发计划完成** ✅