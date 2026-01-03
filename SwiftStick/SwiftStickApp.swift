//
//  SwiftStickApp.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import SwiftUI

@main
struct SwiftStickApp: App {
    #if os(macOS)
    @StateObject var macLogic = MacLogicController()
    #else
    @StateObject var connectionManager = ConnectionManager()
    #endif

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("SwiftStick", systemImage: macLogic.connectionManager.isConnected ? "gamecontroller.fill" : "gamecontroller") {
            MacStatusView(controller: macLogic)
        }
        .menuBarExtraStyle(.menu)
        #else
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
        }
        #endif
    }

    init() {
        // Init logic handled by controllers
    }
}
