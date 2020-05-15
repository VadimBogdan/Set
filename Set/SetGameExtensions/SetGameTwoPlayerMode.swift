//
//  SetGameTwoPlayerMode.swift
//  Set
//
//  Created by Вадим on 14.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

class SetGameTwoPlayerMode
{
    private var playerOneScore = SetCardGameScoreSystem()
    private var playerTwoScore = SetCardGameScoreSystem()
    
    private var turn: Bool = true
    
    private var changeTurnTimer: Timer?
    private var halfTimeTimer: Timer?
    private var timeToChangeTurnPlayerOne = 10.0
    private var timeToChangeTurnPlayerTwo = 10.0
    private let initialTimeToChangeTurn = 10.0
    
    private var onNextPlayerTurn: ((Bool)->Void)?
    private var onTurnHasStarted: ((Bool)->Void)?
    private var onPlayerHasHalfTime: ((Bool)->Void)?
    private var onFinish: (()->Void)?
    
    public var isEnabled: Bool {
        return changeTurnTimer?.isValid ?? false
    }
    
    public func setOnScoreChangedPlayerOne(_ callback: @escaping (Int)->Void) {
        playerOneScore.setOnChangedHandler(callback)
    }
    
    public func setOnScoreChangedPlayerTwo(_ callback: @escaping (Int)->Void) {
        playerTwoScore.setOnChangedHandler(callback)
    }
    
    public func setOnPlayerHasHalfTime(_ callback: @escaping (Bool)->Void) {
        onPlayerHasHalfTime = callback
    }
    
    public func setOnNextPlayerTurn(_ callback: @escaping (Bool)->Void) {
        onNextPlayerTurn = callback
    }

    public func setOnGameHasStarted(_ callback: @escaping (Bool)->Void) {
        onTurnHasStarted = callback
    }
    
    public func setOnGameHasFinished(_ callback: @escaping ()->Void) {
        onFinish = callback
    }
    
    // true - playerOne, false - playerTwo
    public func start(turn: Bool) {
        if changeTurnTimer?.isValid ?? false { return }
        self.turn = turn
        onTurnHasStarted?(turn)
        timeToChangeTurnPlayerOne = initialTimeToChangeTurn
        timeToChangeTurnPlayerTwo = initialTimeToChangeTurn
        changeTurnTimer = Timer.scheduledTimer(withTimeInterval: chooseTurnTime(), repeats: false, block: changeTurn)
        halfTimeTimer = Timer.scheduledTimer(withTimeInterval: chooseTurnTime()/2, repeats: false, block: halfTime)
    }
    
    public func updateScore(_ score: SetCardScorePenalties) {
        updateScore(score.rawValue)
    }
    
    public func updateScore(_ score: Int) {
        if turn {
            playerOneScore.update(score)
        } else {
            playerTwoScore.update(score)
        }
    }
    
    public func updateScoreMatched(_ numberOfSetCardViewsOnScreen: Int) {
        if turn {
            playerOneScore.matched(numberOfSetCardViewsOnScreen)
        } else {
            playerTwoScore.matched(numberOfSetCardViewsOnScreen)
        }
    }
    
    public func updateScoreNotMatched(_ numberOfSetCardViewsOnScreen: Int) {
        if turn {
            playerOneScore.notMatched(numberOfSetCardViewsOnScreen)
        } else {
            playerTwoScore.notMatched(numberOfSetCardViewsOnScreen)
        }
    }
    
    public func playerDealedSetCards() {
        if turn {
            timeToChangeTurnPlayerTwo += initialTimeToChangeTurn/2
        } else {
            timeToChangeTurnPlayerOne += initialTimeToChangeTurn/2
        }
    }
    
    public func reset() {
        playerOneScore.reset()
        playerTwoScore.reset()
        changeTurnTimer?.invalidate()
        halfTimeTimer?.invalidate()
        onFinish?()
    }
    
    fileprivate func chooseTurnTime() -> Double {
        return turn ? timeToChangeTurnPlayerOne : timeToChangeTurnPlayerTwo
    }
    
    fileprivate func changeTurn(timer: Timer) {
        turn = !turn
        onNextPlayerTurn?(turn)
        changeTurnTimer = Timer.scheduledTimer(withTimeInterval: chooseTurnTime(), repeats: false, block: finish)
        halfTimeTimer = Timer.scheduledTimer(withTimeInterval: chooseTurnTime()/2, repeats: false, block: halfTime)
    }
    
    fileprivate func finish(timer: Timer) {
        onFinish?()
    }
    
    fileprivate func halfTime(timer: Timer) {
        onPlayerHasHalfTime?(turn)
    }
}
