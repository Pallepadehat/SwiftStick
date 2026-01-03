//
//  MacStatusView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI
import MultipeerConnectivity

struct MacStatusView: View {
    @ObservedObject var controller: MacLogicController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SwiftStick Status")
                .font(.headline)
                .padding(.bottom, 5)
            
            if !controller.isAccessibilityTrusted {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Permission Missing")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Button("Grant Access") {
                    controller.checkAccessibility()
                }
                Divider()
            }
            
            if controller.connectionManager.isConnected {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Connected")
                }
                if let peer = controller.connectionManager.connectedPeers.first {
                    Text("Controller: \(peer.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button("Disconnect") {
                    controller.connectionManager.stop()
                    // Restart to advertise again? Or just stay disconnected?
                    // Usually we want to restart advertising.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        controller.connectionManager.start()
                    }
                }
            } else {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.gray)
                    Text("Searching for controller...")
                }
            }
            
            Divider()
            
            Button("Quit") {
                #if os(macOS)
                NSApplication.shared.terminate(nil)
                #endif
            }
            .keyboardShortcut("q")
        }
        .padding()
    }
}
