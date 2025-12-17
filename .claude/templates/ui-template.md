# {FULL_TITLE}

**文档编号：UI-{NUMBER}**
**版本：1.0**
**创建日期：{DATE}**
**最后更新：{DATE}**
**关联文档：{RELATED_DOCS}**

## 1. 设计概述

### 1.1 界面名称
{TITLE}

### 1.2 设计目标
{DESCRIPTION}

### 1.3 用户价值
- 提升视觉体验
- 优化交互流程
- 增强品牌一致性

## 2. 界面需求

### 2.1 页面结构 [UI-{NEXT_ID}]
- **主要内容区**：
  - 布局方式：{LAYOUT_TYPE}
  - 间距规范：{SPACING}
  - 对齐方式：{ALIGNMENT}

### 2.2 UI元素列表 [UI-{NEXT_ID+1}]
{UI_ELEMENTS}

### 2.3 交互规范 [UI-{NEXT_ID+2}]
- **手势支持**：
  - 点击：标准点击响应
  - 滑动：{SWIPE_ACTION}
  - 长按：{LONG_PRESS_ACTION}

## 3. 视觉设计

### 3.1 设计原则 [NFR-{NEXT_NFR_ID}]
- **一致性**：遵循整体设计语言
- **简洁性**：信息层次清晰
- **可访问性**：支持无障碍访问

### 3.2 颜色方案
- **主色调**：{PRIMARY_COLOR}
- **辅助色**：{SECONDARY_COLOR}
- **背景色**：{BACKGROUND_COLOR}
- **文字色**：{TEXT_COLOR}

### 3.3 字体规范
- **标题字体**：{TITLE_FONT}
- **正文字体**：{BODY_FONT}
- **字号规范**：
  - 大标题：{TITLE_SIZE}
  - 副标题：{SUBTITLE_SIZE}
  - 正文：{BODY_SIZE}

### 3.4 间距规范
- **组件间距**：{COMPONENT_SPACING}
- **内容边距**：{CONTENT_MARGIN}
- **元素内边距**：{ELEMENT_PADDING}

## 4. 响应式设计

### 4.1 屏幕适配
- **iPhone适配**：
  - SE: {IPHONE_SE_SPEC}
  - 标准: {IPHONE_STANDARD_SPEC}
  - Plus/Max: {IPHONE_PLUS_SPEC}
- **iPad适配**：{IPAD_SPEC}

### 4.2 布局策略
- 使用SwiftUI自适应布局
- 优先使用相对尺寸
- 支持横竖屏切换

## 5. 动画效果

### 5.1 转场动画 [NFR-{NEXT_NFR_ID+1}]
- **进入动画**：{ENTER_ANIMATION}
- **退出动画**：{EXIT_ANIMATION}
- **时长**：{ANIMATION_DURATION}

### 5.2 微交互
- **点击反馈**：{CLICK_FEEDBACK}
- **状态变化**：{STATE_CHANGE}
- **加载动画**：{LOADING_ANIMATION}

## 6. 图标与插图

### 6.1 图标规范
- **风格**：{ICON_STYLE}
- **尺寸**：
  - 小图标：{SMALL_ICON_SIZE}
  - 中图标：{MEDIUM_ICON_SIZE}
  - 大图标：{LARGE_ICON_SIZE}

### 6.2 插图要求
- **格式**：SVG / PNG
- **分辨率**：@2x, @3x
- **主题适配**：支持明暗主题

## 7. 实现说明

### 7.1 技术要求
- 使用SwiftUI实现
- 遵循MVVM架构
- 支持iOS {MIN_IOS_VERSION}+

### 7.2 代码组织
```swift
struct {UI_COMPONENT_NAME}: View {
    var body: some View {
        // UI 实现
    }
}

extension {UI_COMPONENT_NAME} {
    // 私有方法
}
```

## 8. 验收标准

### 8.1 设计验收
- [ ] 视觉效果与设计稿一致
- [ ] 所有设备显示正常
- [ ] 动画效果流畅

### 8.2 交互验收
- [ ] 所有交互正常响应
- [ ] 手势识别准确
- [ ] 状态切换正确

### 8.3 适配验收
- [ ] 不同屏幕尺寸适配良好
- [ ] 横竖屏切换正常
- [ ] 暗黑模式支持

## 9. 相关资源

- [Figma设计稿]({FIGMA_LINK})
- [图标资源]({ICON_RESOURCE})
- [字体文件]({FONT_RESOURCE})

## 10. 相关文档

- [PD-XXX] 对应产品需求文档
- [UI-XXX] 其他界面需求文档

---

**文档结束**