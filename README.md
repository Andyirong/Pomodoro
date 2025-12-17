# 番茄闹钟 App 🍅

一款可爱风格的番茄工作法计时器应用，帮助您提高专注度和工作效率。

## 📱 应用概述

番茄闹钟 App 是一款基于番茄工作法的时间管理应用，采用 Q 版可爱风格设计，提供专注计时、任务管理、白噪音等功能，让时间管理变得更加轻松有趣。

### 主要特点

- 🎀 **Q版可爱风格** - 粉色系界面，搭配萌萌小助手
- ⏰ **灵活计时** - 支持自定义时长和预设时间快速选择
- 📝 **任务管理** - 完整的任务清单和分类管理
- 🎵 **白噪音** - 多种环境音帮助专注
- 🏆 **激励系统** - 积分和成就系统，让坚持更有动力
- 📊 **数据统计** - 详细的使用记录和统计分析

## 🚀 功能特性

### 核心功能

- **倒计时功能**
  - 自定义设置倒计时时间（分钟和秒数）
  - 快速选择预设时间（15、25、30、45、60、90分钟）
  - 上下滑动调整时间
  - 环形进度条显示

- **智能控制**
  - 开始/暂停/继续/重置控制
  - 长按3秒停止闹钟（防误触）
  - 振动反馈和音效提示

- **历史记录**
  - 自动保存最近10条使用记录
  - 相同设置自动计数
  - 一键恢复历史设置

### 任务管理

- **任务清单**
  - 添加、编辑、删除任务
  - 任务分类（工作、学习、阅读、运动等）
  - 优先级设置（高、中、低）
  - 截止日期提醒

- **统计分析**
  - 任务完成率统计
  - 分类时间分析
  - 效率趋势报告

### 健康管理

- **休息提醒**
  - 自定义休息间隔
  - 眼睛保健操指导
  - 伸展运动建议

- **白噪音**
  - 雨声、森林、咖啡厅等环境音
  - 定时关闭功能
  - 音量控制

### 激励系统

- **积分奖励**
  - 完成计时获得积分
  - 连续使用额外奖励
  - 解锁成就获得积分

- **成就系统**
  - 多种成就徽章
  - 连续天数统计
  - 本地排行榜

## 🛠 技术栈

- **开发语言**: Swift
- **UI框架**: SwiftUI
- **数据库**: SQLite
- **最低版本**: iOS 15.0+
- **设备支持**: iPhone

## 📁 项目结构

```
Demo5/
├── Models/                  # 数据模型
│   ├── TimerSettings.swift  # 计时器设置模型
│   ├── Task.swift          # 任务模型
│   ├── Achievement.swift   # 成就模型
│   └── UserStats.swift     # 用户统计模型
├── ViewModels/             # 业务逻辑层
│   ├── TimerViewModel.swift # 计时器逻辑
│   ├── TaskViewModel.swift # 任务管理逻辑
│   └── StatsViewModel.swift # 统计逻辑
├── Views/                  # 界面层
│   ├── TimerView.swift     # 主计时界面
│   ├── TaskListView.swift  # 任务列表
│   ├── AssistantCharacterView.swift # Q版助手
│   └── StatsView.swift     # 统计界面
├── Database/               # 数据库层
│   ├── DatabaseManager.swift # 数据库管理
│   ├── TimerDAO.swift      # 计时器数据访问
│   └── TaskDAO.swift       # 任务数据访问
└── Utils/                  # 工具类
    ├── SoundManager.swift  # 音效管理
    ├── WhiteNoiseManager.swift # 白噪音管理
    └── ThemeStyles.swift   # 主题样式
```

## 🎨 UI设计

### 设计理念
- **色彩方案**: 粉色、紫色、马卡龙色系
- **设计风格**: Q版可爱风格，圆润界面元素
- **动画效果**: Q弹动画，流畅的转场效果

### 核心元素
- **Q版助手**: 萌萌小萝莉角色，根据状态变化表情
- **环形进度**: 直观显示剩余时间
- **毛玻璃效果**: 现代化的半透明界面

## 📊 数据库设计

### 数据表结构

1. **timer_history** - 番茄钟历史记录
   - id, minutes, seconds, note, created_at, usage_count

2. **tasks** - 任务清单
   - id, title, category, priority, deadline, completed, created_at

3. **user_settings** - 用户设置和积分
   - key, value, total_points, current_streak, longest_streak

4. **achievements** - 成就系统
   - id, name, description, unlocked_at, points_required, points_awarded

5. **statistics** - 统计数据
   - date, total_minutes, completed_tomatoes, tasks_done

## 🚀 快速开始

### 环境要求
- Xcode 14.0+
- iOS 15.0+
- Swift 5.7+

### 安装步骤

1. 克隆项目到本地
```bash
git clone [项目地址]
```

2. 打开 Xcode 项目文件
```bash
open Demo5.xcodeproj
```

3. 选择目标设备或模拟器

4. 点击运行按钮构建并启动应用

## 📅 开发计划

### 第一阶段：基础架构（3-4天）
- [x] 项目初始化
- [ ] 数据库设计和实现
- [ ] 基础倒计时功能
- [ ] UI框架搭建

### 第二阶段：核心功能（4-5天）
- [ ] Q版助手角色
- [ ] 任务管理系统
- [ ] 交互功能实现
- [ ] 白噪音功能

### 第三阶段：高级功能（3-4天）
- [ ] 积分和成就系统
- [ ] 休息提醒
- [ ] 音效系统
- [ ] 动画效果

### 第四阶段：优化完善（2-3天）
- [ ] 性能优化
- [ ] UI美化
- [ ] 测试和修复
- [ ] 发布准备

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

### 提交规范
- 使用清晰的提交信息
- 遵循代码风格规范
- 添加必要的注释

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue: [GitHub Issues](项目地址/issues)
- 邮箱: [your-email@example.com]

---

**让每一分钟的专注都充满乐趣！** 🌟

---

*最后更新: 2025-12-17*