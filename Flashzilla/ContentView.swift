//
//  ContentView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 26/11/2021.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    var body: some View {
        Text("Hello, World!")
            .padding(50)
            .background(reduceTransparency ? Color.black : Color.black.opacity(0.5))
            .foregroundColor(Color.white)
            .clipShape(Circle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
