//
//  JoystickView.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import SwiftUI

#if os(iOS)
struct iOSJoystickView: View {
    // Called with x, y values between -1.0 and 1.0
    var onDrag: (Float, Float) -> Void
    
    @State private var thumbOffset: CGSize = .zero
    @State private var isDragging = false
    
    // Config
    private let joystickSize: CGFloat = 100
    private let thumbSize: CGFloat = 50
    private let maxRadius: CGFloat // calculated in init
    
    init(onDrag: @escaping (Float, Float) -> Void) {
        self.onDrag = onDrag
        self.maxRadius = (joystickSize - thumbSize) / 2
    }
    
    var body: some View {
        ZStack {
            // 1. Base Socket (Outer Ring)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.15),
                            Color(white: 0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: joystickSize, height: joystickSize)
                .shadow(color: .white.opacity(0.05), radius: 1, x: -1, y: -1)
                .shadow(color: .black.opacity(0.8), radius: 5, x: 5, y: 5)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(white: 0.1),
                                    Color(white: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                )

            // 2. Inner Recess (Socket floor)
            Circle()
                .fill(Color(white: 0.08)) // Dark recess
                .frame(width: joystickSize - 10, height: joystickSize - 10)
                .shadow(color: .black.opacity(0.9), radius: 4, x: 2, y: 2) // Inner shadow simulation via inset?
                                                                         // Standard shadow goes out. For inner look, we usually overlay a gradient or shadow.
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 4)
                        .blur(radius: 2)
                        .offset(x: 2, y: 2)
                        .mask(Circle().fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                )
            
            // 3. Thumb Stick
            ZStack {
                // Stick Shaft/Base Shadow (illusion of connection)
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: thumbSize + 10, height: thumbSize + 10)
                    .blur(radius: 5)
                    .offset(x: thumbOffset.width * 0.5, y: thumbOffset.height * 0.5 + 5) // Cast shadow moves

                // The Stick Cap
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.25),
                                Color(white: 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Concave top effect
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(white: 0.3), Color(white: 0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        // Subtle grip texture or ring
                        Circle() // High gloss rim
                            .trim(from: 0.1, to: 0.4)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                            .rotationEffect(.degrees(180))
                    )
                    .frame(width: thumbSize, height: thumbSize)
                    // Top highlight
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.05), Color.clear]),
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                    )
            }
            .offset(thumbOffset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        
                        let translation = value.translation
                        let dragDistance = sqrt(pow(translation.width, 2) + pow(translation.height, 2))
                        let dragAngle = atan2(translation.height, translation.width)
                        
                        // Clamping
                        let clampedDistance = min(dragDistance, maxRadius)
                        
                        let x = cos(dragAngle) * clampedDistance
                        let y = sin(dragAngle) * clampedDistance
                        
                        self.thumbOffset = CGSize(width: x, height: y)
                        
                        // Normalizing
                        let normalizedX = Float(x / maxRadius)
                        let normalizedY = Float(y / maxRadius)
                        
                        onDrag(normalizedX, normalizedY)
                    }
                    .onEnded { _ in
                        isDragging = false
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                            thumbOffset = .zero
                        }
                        onDrag(0, 0)
                    }
            )
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        iOSJoystickView { x, y in
            print("Joystick: \(x), \(y)")
        }
    }
}
#endif
