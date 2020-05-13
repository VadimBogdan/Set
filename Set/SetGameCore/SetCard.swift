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
    
    let count: SetCardCountOfFigures
    let color: SetCardFigureColor
    let shading: SetCardFigureShading
    let figure: SetCardFigure
    
    let identifier: Int
    
    init(number: SetCardCountOfFigures, color: SetCardFigureColor, shading: SetCardFigureShading, figure: SetCardFigure) {
        identifier = SetCard.getIdentifier()
        self.count = number
        self.color = color
        self.shading = shading
        self.figure = figure
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
