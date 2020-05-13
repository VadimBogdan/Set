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
    // private(set) var matchedCards = [SetCard]()
    
    init() {
        for number in SetCardCountOfFigures.allCases {
            for color in SetCardFigureColor.allCases {
                for shading in SetCardFigureShading.allCases {
                    for figure in SetCardFigure.allCases {
                        deck.append(SetCard(number: number, color: color, shading: shading, figure: figure))
                    }
                }
            }
        }
        deck.shuffle()
    }
    
    public mutating func getSet() -> [SetCard]? {
        if deck.count == 0 { return nil }
        
        return [deck.removeLast(), deck.removeLast(), deck.removeLast()]
    }
    
    public static func match(set: [SetCard]) -> Bool {
        if set.count < 3 { return false }
        
        if !(((set[0].count == set[1].count) || (set[0].count == set[2].count)) ^ (set[1].count != set[2].count)) {
            return false
        }
        if !(((set[0].color == set[1].color) || (set[0].color == set[2].color)) ^ (set[1].color != set[2].color)) {
           return false
        }
        if !(((set[0].shading == set[1].shading) || (set[0].shading == set[2].shading)) ^ (set[1].shading != set[2].shading)) {
           return false
        }
        if !(((set[0].figure == set[1].figure) || (set[0].figure == set[2].figure)) ^ (set[1].figure != set[2].figure)) {
           return false
        }
        return true
    }
}

enum SetCardFigure: CaseIterable {
    case diamond, oval, squiggle
}

enum SetCardFigureShading: CaseIterable {
    case open, solid, striped
}

enum SetCardFigureColor: CaseIterable {
    case red, green, blue
}

enum SetCardCountOfFigures: Int, CaseIterable {
    case one = 1, two, three
}

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
