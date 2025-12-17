---
description: 归档当前分支并创建新的开发分支
argument-hint: [--push=<boolean>] [--new-branch=<boolean>] [--description=<string>]
---

# 归档当前分支

归档当前分支，可选择是否提交推送以及是否创建新的开发分支。

## 参数说明
- `--push`: 是否提交并推送当前分支（默认：true）
- `--new-branch`: 是否创建新的开发分支（默认：true）
- `--description`: 新分支的描述信息

## 使用示例
- `/archive` - 归档当前分支，推送到远程，并创建新的开发分支
- `/archive --push=false` - 归档当前分支，不推送，但创建新的开发分支
- `/archive --description='新功能开发'` - 归档并创建带有描述的新分支
- `/archive --push=false --new-branch=false` - 仅归档当前分支，不推送也不创建新分支

## 执行步骤
1. 检查当前分支状态
2. 根据参数决定是否提交并推送当前分支
3. 将当前分支移动到 archive/ 目录
4. 根据参数决定是否创建新的开发分支