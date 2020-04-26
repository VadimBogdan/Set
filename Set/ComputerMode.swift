//
//  ComputerMode.swift
//  Set
//
//  Created by Вадим on 26.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct ComputerMode
{
    private(set) var cooldown = 10.0
    
    private var _action: (Timer) -> Void
    private var _anticipation: ((Timer) -> Void)?
    private var _think: (() -> Void)?
    
    private var _actionTimer: Timer?
    private var _anticipationTimer: Timer?
    
    
    public mutating func setThink(_ think: @escaping () -> Void) {
        _think = think
    }
    
    public mutating func setAnticipation(_ anticipation: @escaping (Timer) -> Void) {
        _anticipation = anticipation
    }
    
    public mutating func think() {
        assert(_anticipation != nil, "ComputerMode.think() -> 'Anticipation part does not set.'")
        _think?()
        
        if _anticipationTimer?.isValid ?? false {
            _anticipationTimer?.invalidate()
        }
        if _actionTimer?.isValid ?? false {
            _actionTimer?.invalidate()
        }
        
        _actionTimer = Timer.scheduledTimer(withTimeInterval: cooldown, repeats: false, block: _action)
        _anticipationTimer = Timer.scheduledTimer(withTimeInterval: cooldown - 4, repeats: false, block: _anticipation!)
    }
    
    public init(_ action: @escaping (Timer) -> Void) {
        _action = action
    }
}
