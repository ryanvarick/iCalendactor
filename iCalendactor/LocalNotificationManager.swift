//
//  LocalNotificationManager.swift
//  iCalendactor
//
//  Created by Ryan Varick on 1/19/21.
//

import UserNotifications
import SwiftUI

class LocalNotificationManager: ObservableObject {
    
    var notifications = [Notification]()

    init() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
                if granted == true && error == nil {
                    print("Notifications permitted")
                }
                else {
                    print("Notifications not permitted")
                }
            }
    }
    
    func sendNotification(title: String, subtitle: String?, body: String, launchIn: Double) {
        print("Scheduling...")
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = body
               
//        let imageName = "logo"
//        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
//        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
//        content.attachments = [attachment]
     
        // can also use UNCalendarNotificationTrigger or an UNLocationNotificationTrigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: launchIn, repeats: false)
        let request = UNNotificationRequest(identifier: "demoNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("Scheduled, I think?")
    }

}
