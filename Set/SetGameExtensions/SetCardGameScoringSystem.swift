//
//  SetCardScoreSystem.swift
//  Set
//
//  Created by Вадим on 11.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

protocol SetCardGameScoringSystemDelegate {
    func setCardGameScoringSystem(newScore: Int, from: SetCardGameScoringSystem)
}

class SetCardGameScoringSystem {
    
    public var delegate: SetCardGameScoringSystemDelegate?
    
    private(set) var score = 0
    
    /// action in less than 30 seconds considered good
    private var timeRange: Date?
    
    public func firstTouch() {
        if (timeRange == nil) {
            timeRange = Date()
        }
    }
    
    public func update(_ score: SetCardScorePenalties) {
        self.score += score.rawValue
        postUpdate()
    }
    
    public func update(_ score: Int) {
        self.score += score
        postUpdate()
    }
    
    public func matched(_ numberOfSetCardViewsOnScreen: Int) {
           if Date().timeIntervalSince(timeRange!) < ScoreTime.mid {
               if numberOfSetCardViewsOnScreen <= ScoreCardsCount.mid {
                    update(ScoreRewards.matchedGoodTimeWithFewCards)
               } else {
                    update(ScoreRewards.matchedGoodTimeWithManyCards)
               }
           } else {
               if numberOfSetCardViewsOnScreen <= ScoreCardsCount.mid {
                    update(ScoreRewards.matchedBadTimeWithFewCards)
               } else {
                    update(ScoreRewards.matchedBadTimeWithManyCards)
               }
           }
           timeRange = Date()
       }
       
       public func notMatched(_ numberOfSetCardViewsOnScreen: Int) {
            if Date().timeIntervalSince(timeRange!) < ScoreTime.mid {
                if numberOfSetCardViewsOnScreen <= ScoreCardsCount.mid {
                    update(ScoreRewards.notMatchedGoodTimeWithFewCards)
               } else {
                    update(ScoreRewards.notMatchedGoodTimeWithManyCards)
               }
           } else {
               if numberOfSetCardViewsOnScreen <= ScoreCardsCount.mid {
                    update(ScoreRewards.notMatchedBadTimeWithFewCards)
               } else {
                    update(ScoreRewards.notMatchedBadTimeWithManyCards)
               }
           }
           timeRange = Date()
       }
    
    public func reset() {
        update(-score)
    }
    
    fileprivate func postUpdate() {
        delegate?.setCardGameScoringSystem(newScore: self.score, from: self)
        timeRange = Date()
    }
}

enum SetCardScorePenalties: Int {
    case deselection = -1
    case none = 0
}

struct ScoreRewards {
    public static let matchedGoodTimeWithManyCards = 10
    public static let matchedGoodTimeWithFewCards = 6
    public static let matchedBadTimeWithManyCards = 5
    public static let matchedBadTimeWithFewCards = 3
    
    public static let notMatchedGoodTimeWithManyCards = -4
    public static let notMatchedGoodTimeWithFewCards = -2
    public static let notMatchedBadTimeWithManyCards = -5
    public static let notMatchedBadTimeWithFewCards = -8
}

// Good < mid
struct ScoreTime {
    public static let mid = 12.5
}

// Good < mid
struct ScoreCardsCount {
    public static let mid = 12
}

