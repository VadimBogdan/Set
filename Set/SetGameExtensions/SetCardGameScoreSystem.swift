//
//  SetCardScoreSystem.swift
//  Set
//
//  Created by Вадим on 11.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct SetCardGameScoreSystem
{
    
    private var score = 0
    private var onChangedHandler: ((Int)->Void)?
    
    /// action in less than 30 seconds considered good
    private var timeRange: Date
    
    public mutating func setOnChangedHandler(_ handler: @escaping (Int)->Void) {
        onChangedHandler = handler
    }
    
    init() {
        timeRange = Date()
    }
    
    public mutating func update(_ score: SetCardScorePenalties) {
        self.score += score.rawValue
        onChangedHandler?(self.score)
        timeRange = Date()
    }
    
    public mutating func update(_ score: Int) {
        self.score += score
        update(.none)
    }
    
    public func get() -> Int {
        return score
    }
    
    
    public mutating func matched(_ numberOfSetCardViewsOnScreen: Int) {
        if Date().timeIntervalSince(timeRange) < 30.0 {
            if numberOfSetCardViewsOnScreen <= 12 {
                update(6)
            } else {
                update(3)
            }
        } else {
            if numberOfSetCardViewsOnScreen <= 12 {
                update(1)
            } else {
                update(3)
            }
        }
        timeRange = Date()
    }
    
    public mutating func notMatched(_ numberOfSetCardViewsOnScreen: Int) {
        if Date().timeIntervalSince(timeRange) < 30.0 {
            if numberOfSetCardViewsOnScreen <= 12 {
                update(-4)
            } else {
                update(-2)
            }
        } else {
            if numberOfSetCardViewsOnScreen <= 12 {
                update(-8)
            } else {
                update(-5)
            }
        }
        timeRange = Date()
    }

    public mutating func reset() {
        update(-score)
    }
}

enum SetCardScorePenalties: Int {
    case deselection = -1
    case none = 0
}
