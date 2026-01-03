//
//  InputSimulator.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import Foundation
import CoreGraphics

#if os(macOS)
class MacInputSimulator {
    
    // Track state to avoid spamming events for held keys
    private var activeKeys: Set<CGKeyCode> = []
    
    // Joystick State Tracking
    private var isUpActive = false
    private var isDownActive = false
    private var isLeftActive = false
    private var isRightActive = false
    
    func simulate(packet: GamePacket) {
        switch packet.input {
        case .joystick(let x, let y):
            handleJoystick(x: x, y: y)
        default:
            let keyCode = getKeyCode(for: packet.input)
            let isDown = packet.state == .down
            postKeyEvent(keyCode: keyCode, keyDown: isDown)
        }
    }
    
    private func handleJoystick(x: Float, y: Float) {
        // Threshold for activation
        let threshold: Float = 0.5
        
        // Up/Down
        // Assuming Up is negative Y (standard screen coords), but let's check GamepadView logic
        // In GamepadView we send normalized offset. Touch below center is +Y.
        // So Down is +Y, Up is -Y.
        
        let shouldBeUp = (y < -threshold)
        let shouldBeDown = (y > threshold)
        let shouldBeLeft = (x < -threshold)
        let shouldBeRight = (x > threshold)
        
        updateKey(shouldBeActive: shouldBeUp, isActive: &isUpActive, keyCode: 126) // Up Arrow
        updateKey(shouldBeActive: shouldBeDown, isActive: &isDownActive, keyCode: 125) // Down Arrow
        updateKey(shouldBeActive: shouldBeLeft, isActive: &isLeftActive, keyCode: 123) // Left Arrow
        updateKey(shouldBeActive: shouldBeRight, isActive: &isRightActive, keyCode: 124) // Right Arrow
    }
    
    private func updateKey(shouldBeActive: Bool, isActive: inout Bool, keyCode: CGKeyCode) {
        if shouldBeActive != isActive {
            isActive = shouldBeActive
            postKeyEvent(keyCode: keyCode, keyDown: isActive)
        }
    }
    
    private func getKeyCode(for input: GameInputType) -> CGKeyCode {
        switch input {
        case .buttonA: return 49 // Space
        case .buttonB: return 3  // 'F'
        case .buttonX: return 0  // 'A'
        case .buttonY: return 1  // 'S'
            
        case .dpadUp:    return 126
        case .dpadDown:  return 125
        case .dpadLeft:  return 123
        case .dpadRight: return 124
            
        case .joystick: return 0 // Handled separately
        }
    }
    
    private func postKeyEvent(keyCode: CGKeyCode, keyDown: Bool) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown)
        event?.post(tap: .cghidEventTap)
    }
}
#endif
