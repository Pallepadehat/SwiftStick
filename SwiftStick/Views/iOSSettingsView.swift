//
//  SettingsView.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import SwiftUI


enum ControllerStyle: String, CaseIterable, Identifiable {
    case dpad = "Classic D-Pad"
    case joystick = "Analog Joystick" // "Analog Joystick"
    // Using string raw value for easy storage, but display needs to be handled
    
    var id: String { self.rawValue }
}

struct iOSSettingsView: View {
    @AppStorage("controllerStyle") var controllerStyle: ControllerStyle = .dpad
    @AppStorage("hapticEnabled") var hapticEnabled: Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Controller Layout")) {
                    Picker("Style", selection: $controllerStyle) {
                        ForEach(ControllerStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Feedback")) {
                    Toggle("Haptics", isOn: $hapticEnabled)
                }
                
                Section(footer: Text("SwiftStick V1.2 - Minimalist Edition")) {
                    // Footer
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


