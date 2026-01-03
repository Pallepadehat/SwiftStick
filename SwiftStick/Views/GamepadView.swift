//
//  GamepadView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI

struct GamepadView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    // We can add disconnect button or assume the user swipes down?
    // A small "X" to disconnect at top right?
    
    var body: some View {
        HStack {
            // Left Side: D-Pad
            Spacer()
            DPadView(onInput: sendInput)
            Spacer()
            
            // Center info (Optional)
            VStack {
                Text(connectionManager.connectedPeers.first?.displayName ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.gray)
                Button(action: { connectionManager.stop() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // Right Side: Action Buttons
            ActionButtonsView(onInput: sendInput)
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Dark theme for gamepad
        .statusBar(hidden: true)
    }
    
    func sendInput(_ input: GameInputType, _ state: GameInputState) {
        let packet = GamePacket(input: input, state: state, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
        
        // Haptics on press
        if state == .down {
            HapticManager.shared.light()
        }
    }
}

// MARK: - Components

struct DPadView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        Grid(horizontalSpacing: 5, verticalSpacing: 5) {
            GridRow {
                Color.clear.frame(width: 60, height: 60)
                DPadButton(icon: "arrowtriangle.up.fill", input: .dpadUp, onInput: onInput)
                Color.clear.frame(width: 60, height: 60)
            }
            GridRow {
                DPadButton(icon: "arrowtriangle.left.fill", input: .dpadLeft, onInput: onInput)
                Color.gray.opacity(0.3).frame(width: 60, height: 60).cornerRadius(10)
                DPadButton(icon: "arrowtriangle.right.fill", input: .dpadRight, onInput: onInput)
            }
            GridRow {
                Color.clear.frame(width: 60, height: 60)
                DPadButton(icon: "arrowtriangle.down.fill", input: .dpadDown, onInput: onInput)
                Color.clear.frame(width: 60, height: 60)
            }
        }
    }
}

struct ActionButtonsView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                Color.clear.frame(width: 70, height: 70)
                ActionButton(label: "Y", color: .yellow, input: .buttonY, onInput: onInput)
                Color.clear.frame(width: 70, height: 70)
            }
            GridRow {
                ActionButton(label: "X", color: .blue, input: .buttonX, onInput: onInput)
                Color.clear.frame(width: 70, height: 70)
                ActionButton(label: "B", color: .red, input: .buttonB, onInput: onInput)
            }
            GridRow {
                Color.clear.frame(width: 70, height: 70)
                ActionButton(label: "A", color: .green, input: .buttonA, onInput: onInput)
                Color.clear.frame(width: 70, height: 70)
            }
        }
    }
}

struct DPadButton: View {
    let icon: String
    let input: GameInputType
    let onInput: (GameInputType, GameInputState) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .padding(15)
            .frame(width: 60, height: 60)
            .background(isPressed ? Color.gray : Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onInput(input, .down)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onInput(input, .up)
                    }
            )
    }
}

struct ActionButton: View {
    let label: String
    let color: Color
    let input: GameInputType
    let onInput: (GameInputType, GameInputState) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Text(label)
            .font(.title).bold()
            .frame(width: 70, height: 70)
            .background(isPressed ? color.opacity(0.7) : color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onInput(input, .down)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onInput(input, .up)
                    }
            )
    }
}
