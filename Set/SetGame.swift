//
//  SetGame.swift
//  Set
//
//  Created by Вадим on 22.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct SetGame
{
    private(set) var deck = [SetCard]()
    private(set) var matchedCards = [SetCard]()
    private(set) var selected = [SetCard]()
    
    init() {
        for number in CardNumber.allCases {
            for color in CardColor.allCases {
                for shading in CardShading.allCases {
                    for symbol in CardSymbol.allCases {
                        deck.append(SetCard(number: number, color: color, shading: shading, symbol: symbol))
                    }
                }
            }
        }
        deck.shuffle()
    }
    
    public mutating func getSetFromDeck() -> [SetCard]? {
        if deck.count == 0 { return nil }
        
        return [deck.removeLast(), deck.removeLast(), deck.removeLast()]
    }
    
    public mutating func match(set: [SetCard]) -> Bool {
        if set.count < 3 { return false }

        if !(((set[0].number == set[1].number) || (set[0].number == set[2].number)) ^ (set[1].number != set[2].number)) {
                   return false
        }
        if !(((set[0].color == set[1].color) || (set[0].color == set[2].color)) ^ (set[1].color != set[2].color)) {
           return false
        }
        if !(((set[0].shading == set[1].shading) || (set[0].shading == set[2].shading)) ^ (set[1].shading != set[2].shading)) {
           return false
        }
        if !(((set[0].symbol == set[1].symbol) || (set[0].symbol == set[2].symbol)) ^ (set[1].symbol != set[2].symbol)) {
           return false
        }
        return true
    }
    
    public mutating func updateMatched(set: [SetCard]) {
        if set.count < 3 { return }
        if matchedCards.contains(set[0]) { return }
        
        matchedCards.append(contentsOf: set)
    }
}

enum CardSymbol: CaseIterable {
    case square
    case circle
    case triangle
}

enum CardShading: CaseIterable {
    case striped
    case solid
    case open
}

enum CardColor: CaseIterable {
    case red
    case blue
    case green
}

enum CardNumber: Int, CaseIterable {
    case one = 1
    case two
    case three
}

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
