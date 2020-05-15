//
//  ComputerMode.swift
//  Set
//
//  Created by Вадим on 26.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct SetCardGameBotMode
{
    
    private(set) var cooldown = 10.0
    
    private var action: (Timer) -> Void
    private var anticipation: ((Timer) -> Void)?
    private var think: (() -> Void)?
    
    private var actionTimer: Timer?
    private var anticipationTimer: Timer?
    
    
    public mutating func setThink(_ think: @escaping () -> Void) {
        self.think = think
    }
    
    public mutating func setAnticipation(_ anticipation: @escaping (Timer) -> Void) {
        self.anticipation = anticipation
    }
    
    public mutating func stop() {
        if anticipationTimer?.isValid ?? false {
            anticipationTimer?.invalidate()
        }
        if actionTimer?.isValid ?? false {
            actionTimer?.invalidate()
        }
    }
    
    public mutating func thinking() {
        assert(anticipation != nil, "ComputerMode.think() -> 'Anticipation part does not set.'")
        think?()
        
        actionTimer = Timer.scheduledTimer(withTimeInterval: cooldown, repeats: false, block: action)
        anticipationTimer = Timer.scheduledTimer(withTimeInterval: cooldown - 4, repeats: false, block: anticipation!)
    }
    
    public init(_ action: @escaping (Timer) -> Void) {
        self.action = action
    }
}
