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
    @Published var lastInput: String = "Waiting..."
    
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
            
            // Update UI with friendly input name
            DispatchQueue.main.async {
                self?.lastInput = self?.readableInput(packet.input) ?? ""
            }
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
    
    private func readableInput(_ input: GameInputType) -> String {
        switch input {
        case .buttonA: return "Button A"
        case .buttonB: return "Button B"
        case .buttonX: return "Button X"
        case .buttonY: return "Button Y"
        case .dpadUp: return "Up"
        case .dpadDown: return "Down"
        case .dpadLeft: return "Left"
        case .dpadRight: return "Right"
        case .joystick(let x, let y):
            // Simple direction check for display
            if abs(x) > abs(y) {
                return x > 0 ? "Stick Right" : "Stick Left"
            } else {
                return y > 0 ? "Stick Down" : "Stick Up"
            }
        }
    }
}
#endif
