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
    
    private var notificationManager = LocalNotificationManager()

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
    
    // TBD: NEW SYSTEM
    @Published var eventList: Set<EKEvent> = Set()
    private var cachedEventList: Set<EKEvent> = Set()
    var addedEvents: Set<EKEvent> = Set()
    var removedEvents: Set<EKEvent> = Set()
    @Published var lastUpdate: Date = Date()

    init() {
        calendars = eventStore.calendars(for: .event)
            .sorted() { return $0.title < $1.title }
            .map() { return CalendarItem(calendar: $0) }
        
        // respond to external calendar changes
        eventStoreObserver.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil)
            { _ in self.refresh() }
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
//                    print("\($0.title!) is FREE")
                }
                return true
            }
            .sorted { return $0.startDate < $1.startDate }
        self.events = ekEvents
        
        // NEW
        eventList = Set.init(ekEvents)
        addedEvents = eventList.subtracting(cachedEventList)
        removedEvents = cachedEventList.subtracting(eventList)
        
        let format = NSLocalizedString("number_of_events", comment: "")
        var message = "No changes."
        var sendUpdate = true

        // probably better to compare cached to new first, and if different, then check delta types
        print("load: eventList: \(eventList.count) cached: \(cachedEventList.count); added \(addedEvents.count); removed \(removedEvents.count)")
        if cachedEventList.count == eventList.count {
            if addedEvents.count == removedEvents.count {
                message = "\(Date()): \(String.localizedStringWithFormat(format, addedEvents.count)) changed. Notification supressed."
                sendUpdate = false
            }
        }
        else if addedEvents.count > 0 {
            message = "\(String.localizedStringWithFormat(format, addedEvents.count)) added."
        }
        else if removedEvents.count > 0 {
            message = "\(String.localizedStringWithFormat(format, removedEvents.count)) removed."
        }
        if sendUpdate {
            // clear old notifications?
            // supress calendar toggles, at least the initial one
            // need to distinguish between user action/range aging and event updates (maybe event handler sets a flag?)
            notificationManager.sendNotification(title: "Calendar Updated", body: message, launchIn: 1.0)
        }

        cachedEventList = eventList
        lastUpdate = Date()
    }

    
    func refresh() {
        loadEvents()
    }

    func toggle(calendar: CalendarItem) {
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
    }
    
}
