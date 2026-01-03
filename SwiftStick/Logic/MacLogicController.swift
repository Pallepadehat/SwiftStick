//
//  MacLogicController.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import Foundation
import Combine
import MultipeerConnectivity

#if os(macOS)
class MacLogicController: ObservableObject {
    let connectionManager = ConnectionManager()
    private let inputSimulator = MacInputSimulator()
    private var subscribers = Set<AnyCancellable>()
    
    @Published var isAccessibilityTrusted: Bool = false
    
    init() {
        setupBindings()
        NotificationManager.requestPermission()
        checkAccessibility()
    }
    
    func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        isAccessibilityTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    private func setupBindings() {
        // Wire Networking -> Input
        connectionManager.onInputReceived = { [weak self] packet in
            self?.inputSimulator.simulate(packet: packet)
        }
        
        // Wire Networking -> Notification
        connectionManager.$isConnected
            .dropFirst() // Ignore initial state
            .sink { [weak self] connected in
                if connected {
                    if let peer = self?.connectionManager.connectedPeers.first {
                        NotificationManager.sendConnectedNotification(peerName: peer.displayName)
                    }
                }
            }
            .store(in: &subscribers)
    }
}
#endif
