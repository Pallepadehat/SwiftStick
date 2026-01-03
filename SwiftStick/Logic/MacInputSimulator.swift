//
//  InputSimulator.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
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
        case .joystickLeft(let x, let y):
            handleLeftJoystick(x: x, y: y)
        case .joystickRight(let x, let y):
            handleRightJoystick(x: x, y: y)
        default:
            let keyCode = getKeyCode(for: packet.input)
            let isDown = packet.state == .down
            postKeyEvent(keyCode: keyCode, keyDown: isDown)
        }
    }
    
    private func handleLeftJoystick(x: Float, y: Float) {
        // WASD Movement
        // Threshold for activation
        let threshold: Float = 0.5
        
        let shouldBeUp = (y < -threshold)   // W
        let shouldBeDown = (y > threshold)  // S
        let shouldBeLeft = (x < -threshold) // A
        let shouldBeRight = (x > threshold) // D
        
        // KeyCodes for WASD
        // W=13, A=0, S=1, D=2
        updateKey(shouldBeActive: shouldBeUp, isActive: &isUpActive, keyCode: 13)
        updateKey(shouldBeActive: shouldBeDown, isActive: &isDownActive, keyCode: 1)
        updateKey(shouldBeActive: shouldBeLeft, isActive: &isLeftActive, keyCode: 0)
        updateKey(shouldBeActive: shouldBeRight, isActive: &isRightActive, keyCode: 2)
    }
    
    private func handleRightJoystick(x: Float, y: Float) {
        // Mouse Look (Delta)
        // Only move if significantly pushed to avoid drift
        let deadzone: Float = 0.1
        guard abs(x) > deadzone || abs(y) > deadzone else { return }
        
        // Multiplier for sensitivity
        let sensitivity: Float = 10.0
        
        let dx = CGFloat(x * sensitivity)
        let dy = CGFloat(y * sensitivity)
        
        // Get current mouse position
        guard let currentEvent = CGEvent(source: nil) else { return }
        let currentLoc = currentEvent.location
        
        let newLoc = CGPoint(x: currentLoc.x + dx, y: currentLoc.y + dy)
        
        // Post Mouse Event
        let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: newLoc, mouseButton: .left)
        moveEvent?.post(tap: .cghidEventTap)
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
        case .buttonB: return 56 // Shift (Left) - Changed from 'F' to Shift for Sprint usually
        case .buttonX: return 14 // 'E' - Interact
        case .buttonY: return 15 // 'R' - Reload
            
        case .dpadUp:    return 126 // Up Arrow
        case .dpadDown:  return 125 // Down Arrow
        case .dpadLeft:  return 123 // Left Arrow
        case .dpadRight: return 124 // Right Arrow
            
        case .joystickLeft, .joystickRight: return 0 // Handled separately
        }
    }
    
    private func postKeyEvent(keyCode: CGKeyCode, keyDown: Bool) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown)
        event?.post(tap: .cghidEventTap)
    }
}
#endif
