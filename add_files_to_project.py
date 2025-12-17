#!/usr/bin/env python3
"""
脚本：将新创建的Swift文件添加到Xcode项目中
"""

import os
import uuid
import re

def generate_uuid():
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def main():
    # 新创建的文件列表
    new_files = [
        "Demo5/Database/DatabaseManager.swift",
        "Demo5/Database/TimerDAO.swift",
        "Demo5/Database/TaskDAO.swift",
        "Demo5/Database/StatsDAO.swift",
        "Demo5/Models/TimerSettings.swift",
        "Demo5/Models/Task.swift",
        "Demo5/Models/Achievement.swift",
        "Demo5/Models/UserStats.swift",
        "Demo5/ViewModels/TimerViewModel.swift",
        "Demo5/ViewModels/TaskViewModel.swift",
        "Demo5/Views/TimerView.swift",
        "Demo5/Utils/Color+Extensions.swift",
        "Demo5/Utils/ThemeStyles.swift"
    ]

    project_file = "Demo5.xcodeproj/project.pbxproj"

    # 读取现有的project文件
    with open(project_file, 'r') as f:
        content = f.read()

    # 找到需要插入的位置
    pbx_build_file_section = "/* Begin PBXBuildFile section */"
    pbx_file_reference_section = "/* Begin PBXFileReference section */"
    pbx_group_section = "/* Begin PBXGroup section */"
    sources_build_phase = "/* Begin PBXSourcesBuildPhase section */"

    # 生成新的build files和file references
    new_build_files = []
    new_file_references = []

    for file_path in new_files:
        file_id = generate_uuid()
        build_file_id = generate_uuid()

        new_build_files.append(f"\t\t{build_file_id} /* {os.path.basename(file_path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {os.path.basename(file_path)} */; }};")
        new_file_references.append(f"\t\t{file_id} /* {os.path.basename(file_path)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{os.path.basename(file_path)}\"; sourceTree = \"<group>\"; }};")

    # 在相应位置插入新内容
    # 插入PBXBuildFile
    pos = content.find(pbx_build_file_section) + len(pbx_build_file_section)
    end_pos = content.find("/* End PBXBuildFile section */")
    content = content[:pos] + "\n" + "\n".join(new_build_files) + "\n" + content[end_pos:]

    # 插入PBXFileReference
    pos = content.find(pbx_file_reference_section) + len(pbx_file_reference_section)
    end_pos = content.find("/* End PBXFileReference section */")
    content = content[:pos] + "\n" + "\n".join(new_file_references) + "\n" + content[end_pos:]

    # 更新Sources build phase
    pos = content.find(sources_build_phase)
    end_pos = content.find("/* End PBXSourcesBuildPhase section */")

    # 找到sources的结束位置
    sources_pattern = r'(E760B9A92EF24BD6006DB40F /\* Sources \*/ = \{[\s\S]*?files = \([\s\S]*?)(E760B9B32EF24BD6006DB40F /\* ContentView\.swift in Sources \*/,[\s\S]*?)(\);[\s\S]*?runOnlyForDeploymentPostprocessing = 0;[\s\S]*?\};)'

    # 插入新的source文件
    new_source_files = []
    for i, file_path in enumerate(new_files):
        file_id = generate_uuid()
        build_file_id = generate_uuid()
        new_source_files.append(f"\t\t\t\t{build_file_id} /* {os.path.basename(file_path)} in Sources */,")

    # 在现有sources列表后添加
    pattern = r'(E760B9B32EF24BD6006DB40F /\* ContentView\.swift in Sources \*/,)'
    replacement = r'\1' + '\n' + '\n'.join(new_source_files)
    content = re.sub(pattern, replacement, content)

    # 更新group结构
    # 更新Demo5组
    demo_group_pattern = r'(E760B9AF2EF24BD6006DB40F /\* Demo5 \*/ = \{[\s\S]*?children = \([\s\S]*?E760B9B62EF24BD8006DB40F /\* Preview Content \*/,)'

    # 添加新的组结构
    new_groups = """
				A1000001000000000001 /* Models */ = {isa = PBXGroup; children = (
					A1000002000000000001 /* TimerSettings.swift */,
					A1000003000000000001 /* Task.swift */,
					A1000004000000000001 /* Achievement.swift */,
					A1000005000000000001 /* UserStats.swift */,
				); path = Models; sourceTree = "<group>"; };
				A1000006000000000001 /* ViewModels */ = {isa = PBXGroup; children = (
					A1000007000000000001 /* TimerViewModel.swift */,
					A1000008000000000001 /* TaskViewModel.swift */,
				); path = ViewModels; sourceTree = "<group>"; };
				A1000009000000000001 /* Views */ = {isa = PBXGroup; children = (
					A1000010000000000001 /* TimerView.swift */,
				); path = Views; sourceTree = "<group>"; };
				A1000011000000000001 /* Database */ = {isa = PBXGroup; children = (
					A1000012000000000001 /* DatabaseManager.swift */,
					A1000013000000000001 /* TimerDAO.swift */,
					A1000014000000000001 /* TaskDAO.swift */,
					A1000015000000000001 /* StatsDAO.swift */,
				); path = Database; sourceTree = "<group>"; };
				A1000016000000000001 /* Utils */ = {isa = PBXGroup; children = (
					A1000017000000000001 /* Color+Extensions.swift */,
					A1000018000000000001 /* ThemeStyles.swift */,
				); path = Utils; sourceTree = "<group>"; };
"""

    replacement = f'\\1{new_groups}'
    content = re.sub(demo_group_pattern, replacement, content)

    # 添加子组到主组
    pattern = r'(E760B9AF2EF24BD6006DB40F /\* Demo5 \*/ = \{[\s\S]*?children = \([\s\S]*?E760B9B02EF24BD6006DB40F /\* Demo5App\.swift \*/,[\s\S]*?E760B9B22EF24BD6006DB40F /\* ContentView\.swift \*/,[\s\S]*?E760B9B42EF24BD8006DB40F /\* Assets\.xcassets \*/,[\s\S]*?)E760B9B62EF24BD8006DB40F /\* Preview Content \*/,([\s\S]*?\);[\s\S]*?path = Demo5;[\s\S]*?sourceTree = "<group>";[\s\S]*?\};)'

    new_groups_in_children = """
				A1000001000000000001 /* Models */,
				A1000006000000000001 /* ViewModels */,
				A1000009000000000001 /* Views */,
				A1000011000000000001 /* Database */,
				A1000016000000000001 /* Utils */,"""

    replacement = f'\\1{new_groups_in_children}\n\t\t\t\tE760B9B62EF24BD8006DB40F /* Preview Content */,\\2'
    content = re.sub(pattern, replacement, content)

    # 写回文件
    with open(project_file, 'w') as f:
        f.write(content)

    print("✅ 已添加新文件到Xcode项目中")

if __name__ == "__main__":
    main()