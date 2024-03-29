//
//  ContentView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 26/11/2021.
//

import CoreHaptics
import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @State private var cards = [Card]()
    
    @State private var isActive = true
    @State private var retryCardsAnsweredIncorrectly = true
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showingEditScreen = false
    @State private var showingSettingsScreen = false
    
    @State private var engine: CHHapticEngine?
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(timeRemaining > 0 ? "Time: \(timeRemaining)" : "Time is up!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                    )
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index], retryCardsWronglyAnswered: retryCardsAnsweredIncorrectly) { wrongAnswer in
                            withAnimation {
                                if retryCardsAnsweredIncorrectly && wrongAnswer && cards.count > 1 {
                                    moveCardToBottomOfPile()
                                } else {
                                    removeCard(at: index)
                                }
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibility(hidden: index < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    ZStack {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                    .frame(width: 450, height: 242)
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        isActive = false
                        showingSettingsScreen = true
                    }) {
                        Image(systemName: "gear")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isActive = false
                        showingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                if retryCardsAnsweredIncorrectly && cards.count > 1 {
                                    moveCardToBottomOfPile()
                                } else {
                                    removeCard(at: cards.count - 1)
                                }
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        
                        Spacer()
                        
                        Button(action: {
                            removeCard(at: cards.count - 1)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(isActive ? .white : .gray)
                    .font(.largeTitle)
                    .padding()
                    .disabled(!isActive)
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                if timeRemaining == 0 {
                    // Remove all remaining cards
                    withAnimation {
                        while cards.count > 0 {
                            removeCard(at: cards.count - 1)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if cards.isEmpty == false {
                isActive = true
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        .sheet(isPresented: $showingSettingsScreen, onDismiss: resetCards) {
            SettingsView()
        }
        .onAppear(perform: resetCards)
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        if cards.isEmpty { return }
        
        cards.remove(at: index)
        if cards.count == 1 {
            retryCardsAnsweredIncorrectly = false
        }
        
        if cards.isEmpty {
            isActive = false
            gameOverHaptics()
        }
    }
    
    func moveCardToBottomOfPile() {
        let lastCard = cards.removeLast()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            cards.insert(lastCard, at: 0)
        }
    }
    
    func resetCards() {
        prepareHaptics()
        
        cards = [Card](repeating: Card.example, count: 3)
        timeRemaining = 30
        isActive = true
        retryCardsAnsweredIncorrectly = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
        
        if let codedData = UserDefaults.standard.data(forKey: "CardsSettings") {
            if let decodedData = try? JSONDecoder().decode(Bool.self, from: codedData) {
                retryCardsAnsweredIncorrectly = decodedData
            }
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("there was an error creating the engine: \(error.localizedDescription).")
        }
    }
    
    func gameOverHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1))
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        for i in stride(from: 0.4, to: 0.75, by: 0.15) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
