//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 30/12/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var retryCardsAnsweredIncorrectly = true
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Retry cards answered incorrectly", isOn: $retryCardsAnsweredIncorrectly)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .onAppear(perform: loadSettings)
    }
    
    func dismiss() {
        saveSettings()
        presentationMode.wrappedValue.dismiss()
    }
    
    func saveSettings() {
        if let codedData = try? JSONEncoder().encode(retryCardsAnsweredIncorrectly) {
            UserDefaults.standard.set(codedData, forKey: "CardsSettings")
        }
    }
    
    func loadSettings() {
        if let codedData = UserDefaults.standard.data(forKey: "CardsSettings") {
            if let decodedData = try? JSONDecoder().decode(Bool.self, from: codedData) {
                retryCardsAnsweredIncorrectly = decodedData
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var retry = true
    
    static var previews: some View {
        SettingsView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
