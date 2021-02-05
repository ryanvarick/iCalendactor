//
//  MainView.swift
//  iCalendactor
//
//  Created by Ryan Varick on 1/6/21.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var model: CalendarModel
    var body: some View {
        SettingsView()
        CalendarListView()
        EventListView()
//        SerializedEventsView()
        Section(header: Text("Yeh"), footer: Text("No")) {
            Text("Updated:")
            Text(model.lastUpdate, style: .time)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var model: CalendarModel
    var body: some View {
        Section(header: Text("Settings")) {
            Text("Date Range")
            HStack {
                Group {
                    TextField("Days Back", value: $model.daysBack, formatter: NumberFormatter())
                    Stepper(value: $model.daysBack, in: model.minDays...model.maxDays) { Text("days back") }
                }
                Group {
                    TextField("Days Ahead", value: $model.daysAhead, formatter: NumberFormatter()).fixedSize()
                    Stepper(value: $model.daysAhead, in: model.minDays...model.maxDays) { Text("days ahead") }
                }
            }
        }
    }
}

struct CalendarListView: View {
    @EnvironmentObject var model: CalendarModel
    var body: some View {
        Section(header: Text("Available Calendars (\(model.calendars.count))")) {
            List {
                ForEach(model.calendars) { calendar in
                    HStack {
                        Circle()
                            .foregroundColor(Color(calendar.calendar.color))
                            .frame(width: 10, height: 10)
                        Text(calendar.calendar.title)
                        Button(action: {
                            self.model.toggle(calendar: calendar)
                        }) {
//                            Text("Toggle")
                            // this is not updating, there may be a reference issue
                            if(calendar.enabled) {
                                Text("Remove")
                            }
                            else {
                                Text("Add")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EventListView: View {
    @EnvironmentObject var model: CalendarModel
    var body: some View {
        Section(header: Text("Events (\(model.events.count))")) {
            List {
                ForEach(model.events, id: \.self) { event in
                    HStack {
                        Circle()
                            .foregroundColor(Color(event.calendar.color))
                            .frame(width: 10, height: 10)
                        Text(event.startDate.description)
                        Text(event.title)
                    }
                }
            }
        }
    }
}
