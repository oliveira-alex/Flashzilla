//
//  ContentView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 26/11/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .padding()
            .onTapGesture(perform: simpleSuccess)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
