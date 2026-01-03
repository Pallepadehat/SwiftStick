//
//  iOSGamepadView.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import SwiftUI
import MultipeerConnectivity

#if os(iOS)

// MARK: - Main Container
struct iOSGamepadView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var showingSettings = false
    
    // User Preferences
    @AppStorage("controllerStyle") var controllerStyle: ControllerStyle = .dpad
    @AppStorage("controllerSkin") var controllerSkin: ControllerSkin = .xbox
    @AppStorage("hapticEnabled") var hapticEnabled: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background: Deep Premium Gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.12, green: 0.12, blue: 0.14), // Dark gray center
                        Color.black // Pure black edges
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
                .edgesIgnoringSafeArea(.all)
                
                // Subtle Mesh / Noise Texture (Simulated with random spots if image not available, or just keeping it clean gradient for now)
                
                VStack {
                    // Custom Header (Glassmorphic)
                    HStack {
                        Button(action: { connectionManager.stop() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Disconnect")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                        
                        // Connection Status Pill
                        HStack(spacing: 6) {
                            Circle()
                                .fill(connectionManager.connectedPeers.isEmpty ? Color.red : Color.green)
                                .frame(width: 8, height: 8)
                                .shadow(color: (connectionManager.connectedPeers.isEmpty ? Color.red : Color.green).opacity(0.5), radius: 4)
                            
                            Text(connectionManager.connectedPeers.first?.displayName ?? "Searching...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15) // Slightly more top padding to clear dynamic island/camera in landscape
                    
                    Spacer()
                    
                    // Layout Switcher
                    Group {
                        switch controllerSkin {
                        case .xbox:
                            XboxLayout(onInput: sendInput, onJoystickL: sendJoystickL, onJoystickR: sendJoystickR, skin: controllerSkin)
                        case .playstation:
                            PlayStationLayout(onInput: sendInput, onJoystickL: sendJoystickL, onJoystickR: sendJoystickR, skin: controllerSkin)
                        case .classic:
                            ClassicLayout(onInput: sendInput, onJoystickL: sendJoystickL, onJoystickR: sendJoystickR, skin: controllerSkin)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30) // More bottom padding for aesthetics
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                iOSSettingsView()
            }
            .statusBar(hidden: true)
        }
    }
    
    // Transmit Functions
    func sendInput(_ input: GameInputType, _ state: GameInputState) {
        let packet = GamePacket(input: input, state: state, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
        if hapticEnabled && state == .down { HapticManager.shared.light() }
    }
    
    func sendJoystickL(x: Float, y: Float) {
        let packet = GamePacket(input: .joystickLeft(x: x, y: y), state: .down, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
    }
    
    func sendJoystickR(x: Float, y: Float) {
        let packet = GamePacket(input: .joystickRight(x: x, y: y), state: .down, timestamp: Date().timeIntervalSince1970)
        connectionManager.sendInput(packet)
    }
}

// MARK: - Controller Layouts

// 1. Xbox Layout (Asymmetric)
// Left Stick (Top Left), D-Pad (Bottom Left)
// Buttons (Top Right), Right Stick (Bottom Right)
struct XboxLayout: View {
    let onInput: (GameInputType, GameInputState) -> Void
    let onJoystickL: (Float, Float) -> Void
    let onJoystickR: (Float, Float) -> Void
    let skin: ControllerSkin
    
    var body: some View {
        HStack(spacing: 80) { // Increased spacing between left/right blocks
            // LEFT SIDE
            VStack(spacing: 10) {
                iOSJoystickView(onDrag: onJoystickL)
                Spacer()
                DPadView(onInput: onInput)
            }
            .frame(maxWidth: .infinity)
            
            // RIGHT SIDE
            VStack(spacing: 10) {
                ActionButtonsView(onInput: onInput, skin: skin)
                Spacer()
                iOSJoystickView(onDrag: onJoystickR)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
        .frame(maxHeight: 280) // Tighter vertical constraint
    }
}

// 2. PlayStation Layout (Symmetric)
// D-Pad (Top Left), Left Stick (Bottom Left)
// Buttons (Top Right), Right Stick (Bottom Right)
struct PlayStationLayout: View {
    let onInput: (GameInputType, GameInputState) -> Void
    let onJoystickL: (Float, Float) -> Void
    let onJoystickR: (Float, Float) -> Void
    let skin: ControllerSkin
    
    var body: some View {
        HStack(spacing: 80) {
            // LEFT SIDE
            VStack(spacing: 10) {
                DPadView(onInput: onInput)
                Spacer()
                iOSJoystickView(onDrag: onJoystickL)
            }
            .frame(maxWidth: .infinity)
            
            // RIGHT SIDE
            VStack(spacing: 10) {
                ActionButtonsView(onInput: onInput, skin: skin)
                Spacer()
                iOSJoystickView(onDrag: onJoystickR)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
        .frame(maxHeight: 280)
    }
}

// 3. Classic Layout (Retro)
// D-Pad (Left Center)
// Buttons (Right Center)
// (Scales up D-Pad and Buttons for retro feel, no joysticks)
struct ClassicLayout: View {
    let onInput: (GameInputType, GameInputState) -> Void
    let onJoystickL: (Float, Float) -> Void
    let onJoystickR: (Float, Float) -> Void
    let skin: ControllerSkin
    
    var body: some View {
        HStack(spacing: 80) {
            DPadView(onInput: onInput)
                .scaleEffect(1.3) // Keep retro slightly bigger
            
            ActionButtonsView(onInput: onInput, skin: skin)
                .scaleEffect(1.2)
        }
    }
}

// MARK: - Reusable Components

struct DPadView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    
    var body: some View {
        ZStack {
            // Unify the stored background shape for a seamless look
            Circle()
                .fill(Color(white: 0.1))
                .frame(width: 130, height: 130)
                .shadow(color: .white.opacity(0.05), radius: 1, x: -1, y: -1)
                .shadow(color: .black.opacity(0.8), radius: 5, x: 5, y: 5)
            
            // Cross Container (Recessed)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.08))
                .frame(width: 40, height: 120)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.08))
                .frame(width: 120, height: 40)
            
            // Buttons
            VStack(spacing: 4) {
                DPadButton(icon: "chevron.up", input: .dpadUp, onInput: onInput)
                HStack(spacing: 36) {
                    DPadButton(icon: "chevron.left", input: .dpadLeft, onInput: onInput)
                    DPadButton(icon: "chevron.right", input: .dpadRight, onInput: onInput)
                }
                DPadButton(icon: "chevron.down", input: .dpadDown, onInput: onInput)
            }
        }
        .frame(width: 140, height: 140)
    }
}

struct ActionButtonsView: View {
    let onInput: (GameInputType, GameInputState) -> Void
    let skin: ControllerSkin
    
    var body: some View {
        VStack(spacing: 8) {
            let north = getButtonStyle(pos: .north)
            ActionButton(style: north, input: .buttonY, onInput: onInput)
            
            HStack(spacing: 30) {
                let west = getButtonStyle(pos: .west)
                ActionButton(style: west, input: .buttonX, onInput: onInput)
                
                let east = getButtonStyle(pos: .east)
                ActionButton(style: east, input: .buttonB, onInput: onInput)
            }
            
            let south = getButtonStyle(pos: .south)
            ActionButton(style: south, input: .buttonA, onInput: onInput)
        }
        .frame(width: 140, height: 140)
    }
    
    enum ButtonPos { case north, south, east, west }
    struct ButtonStyleData { let label: String?; let icon: String?; let color: Color }
    
    func getButtonStyle(pos: ButtonPos) -> ButtonStyleData {
        switch skin {
        case .xbox:
            switch pos {
            case .north: return ButtonStyleData(label: "Y", icon: nil, color: .yellow)
            case .south: return ButtonStyleData(label: "A", icon: nil, color: .green)
            case .east:  return ButtonStyleData(label: "B", icon: nil, color: .red)
            case .west:  return ButtonStyleData(label: "X", icon: nil, color: .blue)
            }
        case .playstation:
            switch pos {
            case .north: return ButtonStyleData(label: nil, icon: "triangle.fill", color: .green)
            case .south: return ButtonStyleData(label: nil, icon: "multiply", color: .blue)
            case .east:  return ButtonStyleData(label: nil, icon: "circle", color: .red)
            case .west:  return ButtonStyleData(label: nil, icon: "square.fill", color: Color(red: 1.0, green: 0.4, blue: 0.7))
            }
        case .classic:
            switch pos {
            case .north: return ButtonStyleData(label: "X", icon: nil, color: .gray)
            case .south: return ButtonStyleData(label: "B", icon: nil, color: .yellow)
            case .east:  return ButtonStyleData(label: "A", icon: nil, color: .red)
            case .west:  return ButtonStyleData(label: "Y", icon: nil, color: .gray)
            }
        }
    }
}

struct DPadButton: View {
    let icon: String // expects systemName
    let input: GameInputType
    let onInput: (GameInputType, GameInputState) -> Void
    @State private var isPressed = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(isPressed ? .white : .white.opacity(0.5))
            .frame(width: 35, height: 35)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(white: isPressed ? 0.3 : 0.15),
                                Color(white: isPressed ? 0.2 : 0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(isPressed ? 0.2 : 0.1), .black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isPressed ? .blue.opacity(0.3) : .clear, radius: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
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
    let style: ActionButtonsView.ButtonStyleData
    let input: GameInputType
    let onInput: (GameInputType, GameInputState) -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Glassy Body
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            style.color.opacity(0.1),
                            style.color.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial) // Apple glass effect
                .clipShape(Circle())
                .shadow(color: style.color.opacity(isPressed ? 0.6 : 0.2), radius: isPressed ? 15 : 8, x: 0, y: 0) // Glow
            
            // Inner "Crystal" Detail
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            style.color.opacity(0.8),
                            style.color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            
            // Label / Low-level 3D Text
            if let icon = style.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: style.color, radius: 2)
            } else {
                Text(style.label ?? "")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: style.color, radius: 2)
            }
            
            // Gloss Reflection
            Circle()
                .trim(from: 0.60, to: 0.85)
                .stroke(Color.white.opacity(0.4), lineWidth: 3)
                .rotationEffect(.degrees(10))
                .scaleEffect(0.9)
        }
        .frame(width: 45, height: 45)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
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
