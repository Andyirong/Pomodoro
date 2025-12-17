//
//  Demo5App.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

@main
struct Demo5App: App {

    init() {
        // 应用启动时初始化数据库
        _ = DatabaseManager.shared.openDatabase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
