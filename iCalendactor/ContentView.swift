//
//  ContentView.swift
//  iCalendactor
//
//  Created by Ryan Varick on 12/27/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PermissionsView().padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
