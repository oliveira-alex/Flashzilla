//
//  Card.swift
//  Flashzilla
//
//  Created by Alex Oliveira on 01/12/2021.
//

import Foundation

struct Card {
    let prompt: String
    let answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th doctor in Doctor Who?", answer: "Jodie Whittaker")
    }
}
