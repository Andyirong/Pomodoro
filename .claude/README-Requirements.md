# 需求文档管理系统

本项目使用标准化的需求文档管理系统，通过 `/req-gen` 命令快速生成符合规范的需求文档。

## 快速开始

### 1. 创建新的产品需求
```bash
/req-gen --type PD --title "用户登录" --full-title "用户登录功能需求文档"
```
生成文件：`Requirements/PD-004-用户登录.md`

### 2. 创建UI需求
```bash
/req-gen --type UI --title "登录页" --full-title "登录页面设计规范" --related PD-004
```
生成文件：`Requirements/UI-001-登录页.md`

## 文档类型说明

| 类型 | 说明 | 编号范围 | 模板 |
|------|------|----------|------|
| PD | Product Requirement | PD-001 ~ PD-999 | pd-template.md |
| TD | Technical Requirement | TD-001 ~ TD-999 | td-template.md |
| NFR | Non-Functional Requirement | NFR-001 ~ NFR-999 | nfr-template.md |
| UI | User Interface Requirement | UI-001 ~ UI-999 | ui-template.md |
| QA | Quality Assurance Requirement | QA-001 ~ QA-999 | qa-template.md |
| ARCH | Architecture Requirement | ARCH-001 ~ ARCH-999 | arch-template.md |

## 文档命名规范

- **格式**：`{类型}-{编号}-{核心需求说明}.md`
- **核心需求说明**：≤10字符，优先使用中文
- **示例**：`PD-003-弹窗选择器.md`

## 常用命令示例

### 创建带功能点的需求
```bash
/req-gen --type PD --title "订单系统" --features "创建订单,支付订单,查看订单"
```

### 创建技术需求
```bash
/req-gen --type TD --title "支付集成" --tech-points "支付接口,安全验证,回调处理"
```

### 创建性能需求
```bash
/req-gen --type NFR --title "性能优化" --full-title "系统性能优化需求"
```

### 更新现有文档
```bash
/req-gen --type PD --update PD-002 --title "快速选择" --features "动画优化"
```

## 模板变量说明

### 通用变量
- `{TITLE}` - 简短标题
- `{FULL_TITLE}` - 完整标题
- `{NUMBER}` - 文档编号
- `{DATE}` - 创建日期
- `{DESCRIPTION}` - 功能描述

### 功能相关变量
- `{FEATURES}` - 功能点列表
- `{TECH_POINTS}` - 技术点列表
- `{UI_ELEMENTS}` - UI元素列表

### 自动编号
- `{NEXT_ID}` - 下一个ID号
- `{NEXT_FR_ID}` - 下一个FR编号
- `{NEXT_TR_ID}` - 下一个TR编号
- `{NEXT_NFR_ID}` - 下一个NFR编号

## 目录结构

```
Requirements/
├── PD-001-番茄闹钟.md
├── PD-002-快速选择按钮.md
├── PD-003-弹窗选择器.md
├── UI-001-登录页.md
├── TD-001-支付集成.md
├── NFR-001-性能需求.md
└── ...
```

## 最佳实践

1. **标题选择**：使用简洁的核心功能词，如"登录"、"弹窗选择器"
2. **功能点描述**：每个功能点用逗号分隔，简洁明了
3. **关联文档**：使用文档编号，如"PD-001,PD-002"
4. **更新文档**：使用--update参数更新现有文档

## 注意事项

- 标题长度不超过10个字符
- 文档编号自动分配，无需手动指定
- 生成的文档需要手动完善具体内容
- 保持文档格式的统一性

## 故障排除

### 问题：标题过长
```
错误：标题长度不能超过10个字符
解决：使用更简洁的标题
```

### 问题：编号冲突
```
错误：文档编号已存在
解决：使用--update参数更新现有文档
```

### 问题：关联文档不存在
```
警告：关联文档PD-999不存在
解决：确保关联文档编号正确
```