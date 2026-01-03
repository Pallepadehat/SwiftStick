//
//  MacStatusView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI
import MultipeerConnectivity

#if os(macOS)
struct MacStatusView: View {
    @ObservedObject var controller: MacLogicController
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gamecontroller.fill")
                Text("SwiftStick")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Connection Status
                HStack(spacing: 12) {
                    Circle()
                        .fill(controller.connectionManager.isConnected ? Color.green : Color.orange)
                        .frame(width: 10, height: 10)
                        .shadow(color: controller.connectionManager.isConnected ? .green.opacity(0.5) : .orange.opacity(0.5), radius: 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(controller.connectionManager.isConnected ? "Connected" : "Searching...")
                            .font(.system(size: 14, weight: .medium))
                        
                        if let peer = controller.connectionManager.connectedPeers.first {
                            Text(peer.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Open app on iPhone")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Input Feedback
                HStack {
                    Text("Last Input:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(controller.lastInput)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .transition(.opacity)
                        .id("input_\(controller.lastInput)") // Force redraw/anim
                    
                    Spacer()
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(6)
            }
            .padding()
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button("Quit SwiftStick") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 280) // Fixed width for window style
        .background(Material.regular) // translucent window background
    }
}
#endif
