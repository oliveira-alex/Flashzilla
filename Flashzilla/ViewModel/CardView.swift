//
//  CardView.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 01/12/2021.
//

import SwiftUI

//struct ConditionalBackgroundColor: ViewModifier {
//    var viewOffset: CGSize
//
//    func body(content: Content) -> some View {
//        content
//            .overlay(
//                RoundedRectangle(cornerRadius: 25, style: .continuous)
//                    .fill(defineBackgroundColor(viewOffset))
//            )
//    }
//
//    func defineBackgroundColor(_ offset: CGSize) -> Color {
//        if offset.width > 0 {
//            return Color.green
//        } else if offset.width < 0 {
//            return Color.red
//        } else {
//            return Color.white
//        }
//    }
//}

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    let card: Card
    let retryCardsWronglyAnswered: Bool
    var removal: ((_ wrongAswer: Bool) -> Void)? = nil

    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                            .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(defineBackgroundColor()) // Cleaner then using a view modifier
//                        .modifier(ConditionalBackgroundColor(viewOffset: offset))
                )
                .shadow(radius: 10)
            
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        if offset.width > 0 {
//                            feedback.notificationOccurred(.success)      // Left out for being called too often
                            removal?(false)
                        } else {
                            feedback.notificationOccurred(.error)
                            removal?(true)
                            
                            if retryCardsWronglyAnswered {
                                withAnimation(.spring()) {
                                    offset = .zero
                                }
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
    
    func defineBackgroundColor() -> Color {
        switch offset.width {
        case ..<0:
            return Color.red
        case 0:
            return Color.white
        default:
            return Color.green
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example, retryCardsWronglyAnswered: false)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
