//
//  PermissionsView.swift
//  iCalendactor
//
//  Created by Ryan Varick on 12/29/20.
//

import EventKit
import SwiftUI

struct PermissionsView: View {

    @State var status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    
    var body: some View {
        if status == .authorized {
            CalendarView().environmentObject(CalendarModel())
        }
        else if status == .notDetermined {
//            Image(systemName: "calendar")
            Text("Calendar Access Required").font(.title)
            Text("iCalendactor requires calendar access.")
            Spacer()
            Button(
                action: { requestCalendarAccess() },
                label: { Text("Allow Access") }
            )
        }
        // see https://stackoverflow.com/questions/52751941
        else if status == .denied || status == .restricted {
            Text("Calendar Access Denied").font(.title)
            Text("Fix in System Preferences")
        }
    }

    func requestCalendarAccess() {
        EKEventStore().requestAccess(to: .event) { accessGranted, error in
            if accessGranted { status = .authorized }
            else { status = .denied }
        }
    }
}
