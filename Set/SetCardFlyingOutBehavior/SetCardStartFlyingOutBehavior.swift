//
//  SetCardBehavior.swift
//  Set
//
//  Created by Вадим on 28.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardStartFlyingOutBehavior: UIDynamicBehavior, SetCardFlyingOutBehavior {
    
    var viewsInUse = [SetCardView]()
    
    fileprivate lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    fileprivate lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1.0
        behavior.resistance = 0.0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        switch 3.arc4random {
        case 0: push.angle =  CGFloat.pi/4
        case 1: push.angle =  -CGFloat.pi/4
        case 2: push.angle =  CGFloat.pi/6
        default: push.angle =  -CGFloat.pi/6
        }
        
        push.magnitude = max((item as! UIView).bounds.height, (item as! UIView).bounds.width)/2
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    public func addItem(_ item: UIDynamicItem) {
        viewsInUse.append(item as! SetCardView)
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    public func removeItem(_ item: UIDynamicItem) {
        viewsInUse.remove(item as! SetCardView)
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    public func contains(_ item: UIDynamicItem) -> Bool {
        return viewsInUse.contains(item as! SetCardView)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
