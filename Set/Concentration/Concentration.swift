//
//  Concentration.swift
//  Concentration
//
//  Created by Вадим on 12.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct Concentration
{
    private(set) var cards = [Card]()
    
    private(set) var score = 0
    
    private(set) var flipCount = 0
    
    private var prevCardIndex = 0
    
    private var timing = Date()
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfTheOneAndOnlyFaceUpCard, matchIndex != index {
                // get the time interval from last choose
                let interval = Date().timeIntervalSince(timing)
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    
                    
                   
                    if interval < 0.25 { score += 7 }
                    else if interval < 1.2  { score += 4 }
                    else if interval < 2.0  { score += 3 }
                    else                    { score += 2 }
                    
                } else {
                    
                    let interval = Date().timeIntervalSince(timing)
                    if cards[matchIndex].isSeen {
                        score -= 1
                             if interval > 1.0 { score -= 3 }
                        else if interval > 1.7 { score -= 4 }
                    }
                    if cards[index].isSeen {
                        score -= 1
                             if interval > 1.0 { score -= 3 }
                        else if interval > 1.7 { score -= 4 }
                    }
                }
                cards[index].isFaceUp = true
                cards[index].isSeen = true
                cards[matchIndex].isSeen = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = index
            }
            if prevCardIndex != index { flipCount += 1 }
            prevCardIndex = index
            timing = Date()
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 0..<numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
