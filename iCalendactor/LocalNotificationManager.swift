//
//  LocalNotificationManager.swift
//  iCalendactor
//
//  Created by Ryan Varick on 1/19/21.
//

import UserNotifications
import SwiftUI

class LocalNotificationManager {
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in }
    }
    
    func sendNotification(title: String, body: String, launchIn: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: launchIn, repeats: false)
        let request = UNNotificationRequest(identifier: "icalendactor.update", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
