//
//  NotificationManager.swift
//  SwiftStick
//
//  Created by Patrick Jakobsen on 03/01/2026.
//

import Foundation
import UserNotifications

struct NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    static func sendConnectedNotification(peerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "SwiftStick"
        content.body = "\(peerName) connected and ready to play!"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
