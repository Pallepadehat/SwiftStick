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

struct DPadView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        GeometryReader { geo in
             VStack(spacing: 10) {
                 HStack { Spacer(); DPadButton(icon: "arrowtriangle.up.fill", input: .dpadUp, onInput: onInput); Spacer() }
                 HStack(spacing: 10) {
                     DPadButton(icon: "arrowtriangle.left.fill", input: .dpadLeft, onInput: onInput)
                     Spacer()
                     DPadButton(icon: "arrowtriangle.right.fill", input: .dpadRight, onInput: onInput)
                 }
                 HStack { Spacer(); DPadButton(icon: "arrowtriangle.down.fill", input: .dpadDown, onInput: onInput); Spacer() }
             }
             .padding()
        }
    }
}

struct ActionButtonsView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            ActionButton(label: "Y", color: .yellow, input: .buttonY, onInput: onInput)
            HStack(spacing: 30) {
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
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.9 : 1.0)
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
            .font(.headline)
            .frame(width: 60, height: 60)
            .background(Color(UIColor.secondarySystemBackground))
            .foregroundColor(color) // Use color for text/tint instead of full background
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(UIColor.separator), lineWidth: 1))
            .scaleEffect(isPressed ? 0.92 : 1.0)
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
#endif
