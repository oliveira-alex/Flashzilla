//
//  ContentView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 26/11/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
                print("In progress: \(inProgress)!")
            }) {
                print("Long pressed!")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
