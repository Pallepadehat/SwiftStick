//
//  SettingsView.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import SwiftUI


#if os(iOS)
enum ControllerStyle: String, CaseIterable, Identifiable {
    case dpad = "Classic D-Pad"
    case joystick = "Analog Joystick"
    var id: String { self.rawValue }
}

enum ControllerSkin: String, CaseIterable, Identifiable {
    case xbox = "Xbox"
    case playstation = "PlayStation"
    case classic = "Classic (Nintendo)"
    var id: String { self.rawValue }
}

struct iOSSettingsView: View {
    @AppStorage("controllerStyle") var controllerStyle: ControllerStyle = .dpad
    @AppStorage("controllerSkin") var controllerSkin: ControllerSkin = .xbox
    @AppStorage("hapticEnabled") var hapticEnabled: Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Layout")) {
                    Picker("Input Style", selection: $controllerStyle) {
                        ForEach(ControllerStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Theme")) {
                    Picker("Controller Skin", selection: $controllerSkin) {
                        ForEach(ControllerSkin.allCases) { skin in
                            Text(skin.rawValue).tag(skin)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Feedback")) {
                    Toggle("Haptics", isOn: $hapticEnabled)
                }
                
                Section(footer: Text("SwiftStick V1.0 - Made by @Pallepadehat")) {
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
#endif


