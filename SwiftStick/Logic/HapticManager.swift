//
//  HapticManager.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import Combine

#if os(iOS)
import UIKit
import CoreHaptics
#endif



class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    #if os(iOS)
    private var engine: CHHapticEngine?
    
    // Legacy generators for fallback or simple UI ticks
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.stoppedHandler = { reason in
                print("Haptic Engine stopped: \(reason)")
            }
            
            engine?.resetHandler = { [weak self] in
                print("Haptic Engine resetting")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart engine: \(error)")
                }
            }
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Legacy / Standard Interactions
    
    func light() {
        lightGenerator.impactOccurred()
    }
    
    func medium() {
        mediumGenerator.impactOccurred()
    }
    
    func heavy() {
        heavyGenerator.impactOccurred()
    }
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Core Haptics Implementation
    
    func complexSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    // Plays a custom transient haptic
    func playCustom(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
    
    #else
    // MACOS NO-OP STUBS
    init() {}
    func light() {}
    func medium() {}
    func heavy() {}
    func success() {}
    func error() {}
    func prepareHaptics() {}
    func complexSuccess() {}
    func playCustom(intensity: Float, sharpness: Float) {}
    #endif
}
