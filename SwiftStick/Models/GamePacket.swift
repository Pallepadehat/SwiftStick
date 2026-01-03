//
//  GamePacket.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import Foundation

enum GameInputType: Codable {
    case buttonA
    case buttonB
    case buttonX
    case buttonY
    case dpadUp
    case dpadDown
    case dpadLeft
    case dpadRight
    // Future: Joysticks, Triggers
}

enum GameInputState: Codable {
    case down // Pressed
    case up   // Released
}

struct GamePacket: Codable {
    let input: GameInputType
    let state: GameInputState
    let timestamp: TimeInterval // Good for lag compensation or debugging
}
