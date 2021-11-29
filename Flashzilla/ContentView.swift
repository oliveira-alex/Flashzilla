//
//  ContentView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 26/11/2021.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect() // The tolerance parameter opens a windows in which the timer can run, so iOS can group it with other timers and thus optimize battery life
    @State private var counter = 0
    
    var body: some View {
        Text("Hello, World!")
            .onReceive(timer) { time in
                if self.counter == 5 {
                    self.timer.upstream.connect().cancel()
                } else {
                    print("The time is now \(time)")
                }
                
                self.counter += 1
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
