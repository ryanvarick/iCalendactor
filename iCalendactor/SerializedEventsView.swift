//
//  ICSView.swift
//  iCalendactor
//
//  Created by Ryan Varick on 12/31/20.
//

import EventKit
import SwiftUI

struct SerializedEventsView: View {
    
    private let icsPath: String = "ryanvarick.com/ryanvarick.com/calendar/feed.ics"
    @State var isUpdating = false
    
    @EnvironmentObject var model: CalendarModel

    
//    var events: [EKEvent]
    var serializedEvents: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm'00'"

        var str: String = ""
        str += "BEGIN:VCALENDAR\n"
        str += "VERSION:2.0\n"
        str += "CALSCALE:GREGORIAN\n"
        str += "X-WR-CALNAME:ryan@ryanvarick.com\n"
        
        for event in model.events {
            let startDate = dateFormatter.string(from: event.startDate)
            let endDate = dateFormatter.string(from: event.endDate)
            str += "BEGIN:VEVENT\n"
            str += "DTSTART;TZID=America/Los_Angeles:\(startDate)\n"
            str += "DTEND;TZID=America/Los_Angeles:\(endDate)\n"
            str += "SUMMARY:busy\n"
            str += "END:VEVENT\n"
        }
        
        return str + "END:VCALENDAR\n"
    }
    
    var body: some View {
        Section(header: Text("Serialzied ICS (\(model.events.count))")) {
            Button(
                action: { serialize() },
                label: {
                    Text("Export .ics")
                    if(isUpdating) { ProgressView() }
                }
            )
            ScrollView {
                Text(serializedEvents)
            }
        }
    }
    
    // decouple; proxy through a project-level object
//    init(events: [EKEvent]) {
//        self.events = events
//    }
    
    func serialize() {
//        let fileName = UUID().description
        let fileName = "index"
        let DocumentDirURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("ics")
        print("FilePath: \(fileURL.path)")
        
        let writeString = serializedEvents
        do {
            // Write to the file
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
     
//        var readString = "" // Used to store the file contents
//        do {
//            // Read the file contents
//            readString = try String(contentsOf: fileURL)
//        } catch let error as NSError {
//            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//        }
//        print("File Text: \(readString)")
        
        isUpdating = true
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/scp")
        task.arguments = [fileURL.path, "scp://" + icsPath]
        task.launch()
        task.waitUntilExit()
        isUpdating = false
    }
}
