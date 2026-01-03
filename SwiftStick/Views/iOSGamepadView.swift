//
//  GamepadView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI
import MultipeerConnectivity


#if os(iOS)
struct iOSGamepadView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var showingSettings = false
    
    // User Preferences
    @AppStorage("controllerStyle") var controllerStyle: ControllerStyle = .dpad
    @AppStorage("hapticEnabled") var hapticEnabled: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                // Controller Area
                HStack(spacing: 40) {
                    // Left Side: D-Pad OR Joystick
                    Group {
                        if controllerStyle == .joystick {
                            iOSJoystickView { x, y in
                                sendJoystick(x: x, y: y)
                            }
                        } else {
                            DPadView(onInput: sendInput)
                        }
                    }
                    .frame(width: 200, height: 200)
                    
                    Spacer()
                    
                    // Right Side: Action Buttons
                    ActionButtonsView(onInput: sendInput)
                        .frame(width: 200, height: 200)
                }
                .padding(.horizontal)
            }
            .navigationTitle(connectionManager.connectedPeers.first?.displayName ?? "Connected")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Disconnect", role: .destructive) {
                        connectionManager.stop()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                iOSSettingsView()
            }
        }
    }
    
    func sendInput(_ input: GameInputType, _ state: GameInputState) {
        let packet = GamePacket(input: input, state: state, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
        
        // Haptics
        if hapticEnabled && state == .down {
            HapticManager.shared.light()
        }
    }
    
    func sendJoystick(x: Float, y: Float) {
        let packet = GamePacket(input: .joystick(x: x, y: y), state: .down, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
    }
}

// MARK: - Components

// MARK: - Components

struct DPadView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cross Background (Optional: adds a "connected" feel)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 50, height: 160)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 160, height: 50)
                
                // Buttons
                VStack(spacing: 8) {
                    DPadButton(icon: "arrowtriangle.up.fill", input: .dpadUp, onInput: onInput)
                    HStack(spacing: 48) { // Wide spacing for Left/Right
                        DPadButton(icon: "arrowtriangle.left.fill", input: .dpadLeft, onInput: onInput)
                        DPadButton(icon: "arrowtriangle.right.fill", input: .dpadRight, onInput: onInput)
                    }
                    DPadButton(icon: "arrowtriangle.down.fill", input: .dpadDown, onInput: onInput)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ActionButtonsView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        VStack(spacing: 20) { // Increased vertical spacing
            ActionButton(label: "Y", color: .yellow, input: .buttonY, onInput: onInput)
            HStack(spacing: 50) { // Increased horizontal spacing
                ActionButton(label: "X", color: .blue, input: .buttonX, onInput: onInput)
                ActionButton(label: "B", color: .red, input: .buttonB, onInput: onInput)
            }
            ActionButton(label: "A", color: .green, input: .buttonA, onInput: onInput)
        }
        .padding()
    }
}

struct DPadButton: View {
    let icon: String
    let input: GameInputType
    let onInput: (GameInputType, GameInputState) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(.primary.opacity(0.8))
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            HapticManager.shared.light()
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
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 65, height: 65)
            .background(
                Circle()
                    .fill(color.gradient) // Use gradient for a nice "button" feel
                    .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 4)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            HapticManager.shared.medium()
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
#endif
