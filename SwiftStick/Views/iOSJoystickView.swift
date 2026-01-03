//
//  JoystickView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI

#if os(iOS)
struct iOSJoystickView: View {
    // Called with x, y values between -1.0 and 1.0
    var onDrag: (Float, Float) -> Void
    
    @State private var thumbOffset: CGSize = .zero
    @State private var isDragging = false
    
    // Config
    private let joystickSize: CGFloat = 150
    private let thumbSize: CGFloat = 80
    private let maxRadius: CGFloat // calculated in init
    
    init(onDrag: @escaping (Float, Float) -> Void) {
        self.onDrag = onDrag
        self.maxRadius = (joystickSize - thumbSize) / 2
    }
    
    var body: some View {
        ZStack {
            // Base Background
            Circle()
                .stroke(Color(UIColor.separator), lineWidth: 2)
                .background(Circle().fill(Color(UIColor.secondarySystemBackground)))
                .frame(width: joystickSize, height: joystickSize)
            
            // Thumb Stick
            Circle()
                .fill(Color.primary)
                .frame(width: thumbSize, height: thumbSize)
                .shadow(radius: 1)
                .offset(thumbOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            
                            // Calculate vector from center
                            let vector = CGVector(dx: value.location.x, dy: value.location.y)
                            // Start point is center due to ZStack? No, DragGesture local coordinate space
                            // Actually easiest is to track translation
                            
                            // Let's use translation directly + rubberband effect?
                            // Simpler: limit distance
                            
                            var dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            let dragAngle = atan2(value.translation.height, value.translation.width)
                            
                            // Clamp distance
                            if dragDistance > maxRadius {
                                dragDistance = maxRadius
                            }
                            
                            let x = cos(dragAngle) * dragDistance
                            let y = sin(dragAngle) * dragDistance
                            
                            self.thumbOffset = CGSize(width: x, height: y)
                            
                            // Normalize to -1.0 ... 1.0
                            // Note: Y is usually inverted in games (Up is negative in screen coords but positive in logic?)
                            // Let's keep screen coords: Down is +Y, Up is -Y.
                            // We can invert later if needed. Standard: Up = -1.0
                            let normalizedX = Float(x / maxRadius)
                            let normalizedY = Float(y / maxRadius)
                            
                            onDrag(normalizedX, normalizedY)
                        }
                        .onEnded { _ in
                            isDragging = false
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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
