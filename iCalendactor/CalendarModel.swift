//
//  CalendarModel.swift
//  iCalendactor-v6c
//
//  Created by Ryan Varick on 1/10/21.
//

import EventKit
import SwiftUI

class CalendarModel: ObservableObject {
    
    private let eventStore = EKEventStore()
    private let eventStoreObserver = NotificationCenter.default

    let minDays: Int = 1
    let maxDays: Int = 365

    @Published var daysBack: Int = 7 {
        didSet { refresh() }
    }
    @Published var daysAhead: Int = 31 {
        didSet { refresh() }
    }
    
    @Published var calendars: [CalendarItem]
    @Published var events: [EKEvent] = []

    init() {
        calendars = eventStore.calendars(for: .event)
            .sorted() { return $0.title < $1.title }
            .map() { return CalendarItem(calendar: $0) }
        
        // respond to external calendar changes
        eventStoreObserver.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil)
            { _ in self.refresh() }
        
        // add: daily, return from sleep
    }
    
    func loadEvents() {
        let now = Date()
        let secondsPerDay = 24 * 60 * 60 // fix

        // empty predicate returns all events for some reason???
        var enabledCalendars: [EKCalendar] = calendars
            .filter() { return $0.enabled }
            .map() { return $0.calendar }
        if enabledCalendars.isEmpty { enabledCalendars = [EKCalendar()] }
        
        let eventsPredicate = eventStore.predicateForEvents(
            withStart: now - TimeInterval(daysBack * secondsPerDay),
            end: now + TimeInterval(daysAhead * secondsPerDay),
            calendars: enabledCalendars
        )
        
        // FIXME: Filter on free
        let ekEvents = eventStore.events(matching: eventsPredicate)
            .filter() {
                if $0.availability == .free {
                    print("\($0.title!) is FREE")
                }
                return true
            }
            .sorted { return $0.startDate < $1.startDate }
        self.events = ekEvents
    }

    
    func refresh() {
        print("refresh: fired")
        loadEvents()
    }

    func toggle(calendar: CalendarItem) {
        print("toggled \(calendar.calendar.title);  \(calendar.id)")
        calendar.toggle()
        refresh()
        // stupid ugly hack
        let c = CalendarItem(calendar: EKCalendar())
        calendars.append(c)
        calendars.removeLast()
    }

}


class CalendarItem: Identifiable, ObservableObject {

    var calendar: EKCalendar
    @Published var enabled: Bool
    var id = UUID()

    init(calendar: EKCalendar) {
        self.calendar = calendar
        self.enabled = false
    }
    
    func toggle() {
        enabled = !enabled
        print("toggling  \(id) state to \(enabled)")
    }
    
}
