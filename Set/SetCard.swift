//
//  SetCard.swift
//  Set
//
//  Created by Вадим on 22.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct SetCard: Equatable
{
    
    let number: CardNumber
    let color: CardColor
    let shading: CardShading
    let symbol: CardSymbol
    
    let identifier: Int
    
    init(number: CardNumber, color: CardColor, shading: CardShading, symbol: CardSymbol) {
        identifier = SetCard.getIdentifier()
        self.number = number
        self.color = color
        self.shading = shading
        self.symbol = symbol
    }
    
    private static var identityFactory = 0
    
    private static func getIdentifier() -> Int {
        SetCard.identityFactory += 1
        return SetCard.identityFactory
    }
    
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func != (lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
