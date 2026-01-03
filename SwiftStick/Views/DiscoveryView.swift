//
//  DiscoveryView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI
import MultipeerConnectivity

struct DiscoveryView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        NavigationView {
            VStack {
                if connectionManager.foundPeers.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Searching for SwiftStick Macs...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(connectionManager.foundPeers, id: \.self) { peer in
                        Button(action: {
                            connectionManager.invitePeer(peer)
                            HapticManager.shared.medium()
                        }) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text(peer.displayName)
                                        .font(.headline)
                                    Text("Tap to connect")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Connect Controller")
            .onChange(of: connectionManager.isConnected) { 
                if connectionManager.isConnected {
                    HapticManager.shared.success()
                }
            }
        }
    }
}
