//
//  InputSimulator.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import Foundation
import CoreGraphics

#if os(macOS)
class InputSimulator {
    // Key codes (Carbon)
    // 0: A
    // 1: S
    // 2: D
    // 13: W
    // 49: Space
    // 123: Left Arrow
    // 124: Right Arrow
    // 126: Up Arrow
    // 125: Down Arrow
    
    // MVP Mapping:
    // A Button -> Space
    // B Button -> Cmd (or something else?) Let's say 'F' for Interact (3)
    // Dpad -> Arrow keys
    
    func simulate(packet: GamePacket) {
        let keyCode = getKeyCode(for: packet.input)
        let isDown = packet.state == .down
        
        postKeyEvent(keyCode: keyCode, keyDown: isDown)
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
        }
    }
    
    private func postKeyEvent(keyCode: CGKeyCode, keyDown: Bool) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown)
        event?.post(tap: .cghidEventTap)
    }
}
#endif
