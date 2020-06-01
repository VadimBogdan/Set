//
//  SetCardEndFlyingOutBehavior.swift
//  Set
//
//  Created by Вадим on 01.06.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardEndFlyingOutBehavior: UIDynamicBehavior, SetCardFlyingOutBehavior {
    
    var viewsInUse = [SetCardView]()
    
    fileprivate func snap(_ item: UIDynamicItem, _ pileFrame: CGRect) {
        let snap = UISnapBehavior(item: item,
                                  snapTo: CGPoint(
                                    x: pileFrame.midX,
                                    y: pileFrame.midY
        ))
        snap.damping = 1.0
        addChildBehavior(snap)
        let card = (item as! SetCardView)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.45,
            delay: 0.25,
            options: [.allowAnimatedContent],
            animations: {
                card.transform = .identity
                card.frame = pileFrame
            },
            completion: { finish in
                self.removeChildBehavior(snap)
                UIView.transition(
                     with: card,
                     duration: 0.55,
                     options: [.transitionFlipFromLeft],
                     animations: {
                         card.isFaceUp = false
                     },
                     completion: { [weak self] finish in
                        card.removeFromSuperview()
                        self?.viewsInUse.remove(card)
                    })
            })
    }
    
    func addItem(_ item: UIDynamicItem, pileFrame: CGRect) {
        viewsInUse.append(item as! SetCardView)
        snap(item, pileFrame)
    }
    
    func contains(_ item: UIDynamicItem) -> Bool {
        return viewsInUse.contains(item as! SetCardView)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
