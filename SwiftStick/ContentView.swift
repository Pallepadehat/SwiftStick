//
//  ContentView.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import SwiftUI

#if os(iOS)
struct ContentView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        if connectionManager.isConnected {
            iOSGamepadView()
                .transition(.opacity)
        } else {
            iOSDiscoveryView()
                .transition(.opacity)
        }
    }
}
#endif
