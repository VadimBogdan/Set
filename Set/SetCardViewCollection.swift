//
//  SetView.swift
//  Set
//
//  Created by Вадим on 08.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardViewCollection: UIView, SetCardGameScoringSystemDelegate {
    
    public var delegate: SetCardViewCollectionDelegate? {
        didSet {
            score.delegate = self
        }
    }

    private lazy var grid = Grid(layout: .aspectRatio(6.0/5.0), frame: bounds)
    
    private lazy var selected = [SetCardView]()
    
    private lazy var score = SetCardGameScoringSystem()
    
    private var cheat = SetCardGameCheat()
    
    private var isSelectedCardsMakeAMatch: Bool {
        get {
            SetGame.match(set: selected.map { $0.setCard! })
        }
    }
    
    // Animations
    private lazy var animator = UIDynamicAnimator(referenceView: superview!)
    private lazy var cardStartFlyingOutBehavior = SetCardStartFlyingOutBehavior(in: animator)
    private lazy var cardEndFlyingOutBehavior = SetCardEndFlyingOutBehavior(in: animator)

    func setCardGameScoringSystem(newScore: Int, from: SetCardGameScoringSystem) {
        delegate?.setCardViewCollection(currentScore: newScore, self)
    }
    ///
    // Public API
    ///
    public func cheatSet() -> Bool {
        if isSelectedCardsMakeAMatch {
            self.respondToMatchedSet(self.delegate?.setCardViewCollection(isDeckEmptyFrom: self) ?? true)
            return false
        } else {
            guard let matches = cheat.detectSet(in: setCardViewsThatNeedToBeRearranged) else { return false }
            deselectSelectedSetCardViews()
            matches[0].forEach
            {
                setCardViewHasBeenTouched(setCardView: $0)
            }
            return true
        }
    }
    
    public func add(set: [SetCard]?) {
        guard let set = set else { return }
        assert(setCardViews().count < 81, "Number of set cards cannot be larger than 81.")
        doPenaltyIfSomeMatchesAvailable()
        delegate?.setCardViewCollection(resetBotModeFrom: self)
        updateSubviews(set)
    }
    
    public func initialSetCards(_ setCards: [SetCard]) {
        updateSubviews(setCards)
    }
    
    public func reset() {
        setCardViews().forEach { $0.removeFromSuperview() }
        selected.removeAll()
        score.reset()
    }
    
    fileprivate func doPenaltyIfSomeMatchesAvailable() {
        /// Penalty for not matched matches on screen
        if selected.count != 3 {
            if let matches = cheat.detectSet(in: setCardViews()) {
                score.update(-matches.count)
            }
        }
    }
    
    fileprivate func updateSubviews(_ set: [SetCard]) {
        if isSelectedCardsMakeAMatch {
            replaceMatchedSetCards(fromSetToSetCardView(set))
        } else {
            addSetCardViews(fromSetToSetCardView(set))
        }
    }
    
    fileprivate func replaceMatchedSetCards(_ set: [SetCardView]) {
        for index in selected.indices {
            let card = selected[index]
            replacingFrames.append(selected[index].frame)
            animateFlyingOut(card)
        }
        animateReplacingDeal(set)
        deselectSelectedSetCardViews()
    }
    
    fileprivate var replacingFrames = [CGRect]()
    
    fileprivate func animateFlyingOut(_ card: SetCardView) {
        bringSubviewToFront(card)
        cardStartFlyingOutBehavior.addItem(card)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.cardStartFlyingOutBehavior.removeItem(card)
            let pileFrame = self.delegate!.setCardViewCollection(discardPileFrameFor: self)
            self.cardEndFlyingOutBehavior.addItem(card, pileFrame: pileFrame)
        }
    }
    
    fileprivate func animateReplacingDeal(_ set: [SetCardView]) {
        var delay = AnimationConstants.dealCardDelay * 2
        for index in replacingFrames.indices {
            let card = set[index]
            addSubview(card)
            fillCardPropeties(card)
            card.frame = delegate!.setCardViewCollection(deckFrameFor: self)
            let frame = replacingFrames[index]
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: delay,
                options: [.allowAnimatedContent],
                animations: {
                    card.frame = frame
                },
                completion: { finish in
                    if (card.isFaceUp) { return }
                    UIView.transition(
                        with: card,
                        duration: 0.55,
                        options: [.transitionFlipFromLeft],
                        animations: {
                            card.isFaceUp = true
                    })
            })
            
            delay += AnimationConstants.dealCardDelay
        }
        replacingFrames.removeAll()
    }
    
    fileprivate var throttlingTimer: Timer?
    fileprivate var intermediaryStorage = [SetCardView]()
    
    fileprivate func fillCardPropeties(_ card: SetCardView) {
        card.addTarget(self, action: #selector(setCardViewHasBeenTouched), for: .touchUpInside)
        card.backgroundColor = .clear
        card.contentMode = .redraw
        card.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
    }
    
    fileprivate func addSetCardViews(_ set: [SetCardView]) {
        set.forEach {
            fillCardPropeties($0)
            intermediaryStorage.append($0)
        }
        if throttlingTimer == nil || throttlingTimer?.isValid == false {
            throttlingTimer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(throttleUpdates),
                userInfo: intermediaryStorage.count,
                repeats: false
            )
            needsRearange = true
        }
    }
    
    @objc fileprivate func throttleUpdates(timer: Timer) {
        if (timer.userInfo as? Int) == intermediaryStorage.count {
            intermediaryStorage.forEach {
                addSubview($0)
                $0.frame = delegate!.setCardViewCollection(deckFrameFor: self)
            }
            intermediaryStorage = []
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } else {
            Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(throttleUpdates),
                userInfo: intermediaryStorage.count,
                repeats: false
            )
        }
    }
    
    fileprivate func respondToMatchedSet(_ deckIsEmpty: Bool) {
        if deckIsEmpty {
            matchIsFoundButDeckIsEmpty()
            needsRearange = true
            setNeedsLayout()
            layoutIfNeeded()
        } else {
            delegate?.setCardViewCollection(addSetTo: self)
            needsRearange = false
        }
    }
    
    fileprivate func matchIsFoundButDeckIsEmpty() {
        selected.forEach { animateFlyingOut($0) }
        deselectSelectedSetCardViews()
    }
    
    fileprivate func deselectSelectedSetCardViews() {
        selected.forEach { $0.deselect() }
        selected.removeAll()
    }
    
    fileprivate func selectSetCardView(_ setCardView: SetCardView, with color: UIColor) {
        selected.append(setCardView)
        setCardView.select(with: SetCardViewBorderColors.select)
    }
    
    fileprivate func deselectSetCardView(_ setCardView: SetCardView) {
        score.update(.deselection)
        selected.remove(setCardView)
        setCardView.deselect()
    }
    
    /// Touch action
    @objc fileprivate func setCardViewHasBeenTouched(setCardView: SetCardView!) {
        if isSelectedCardsMakeAMatch {
            /// Don't select matched cards until they're replaced.
            if selected.contains(setCardView) { return }
            respondToMatchedSet(delegate?.setCardViewCollection(isDeckEmptyFrom: self) ?? true)
        } else if selected.count == 3 {
            deselectSelectedSetCardViews()
        }

        if !selected.contains(setCardView) {
            selectSetCardView(setCardView, with: SetCardViewBorderColors.select)
        } else {
            deselectSetCardView(setCardView)
        }
        
        if selected.count == 3 {
            handleThreeSelectedViewCards()
        }
        if selected.count == 1 {
            score.firstTouch()
        }
    }
    
    @objc public func handleSwipeGestures(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            delegate?.setCardViewCollection(addSetTo: self)
        }
    }
    
    @objc public func handleRotationGestures(gesture: UIRotationGestureRecognizer) {
        if gesture.state == .ended {
            reshuffleSetCardViews()
        }
    }
    
    fileprivate func reshuffleSetCardViews() {
        let shuffled = setCardViews().map { $0.setCard }.shuffled()
        for shuffledIndex in shuffled.indices {
            setCardViews()[shuffledIndex].setNewSetCard(setCard: shuffled[shuffledIndex]!)
        }
    }
    
    fileprivate func handleThreeSelectedViewCards() {
        if isSelectedCardsMakeAMatch {
            selected.forEach { $0.select(with: SetCardViewBorderColors.correct) }
            score.matched(subviews.count)
        } else {
            score.notMatched(setCardViews().count)
            selected.forEach { $0.select(with: SetCardViewBorderColors.mistake) }
        }
    }
    
    // helper field to adjust deal animation when flying out cards occur
    fileprivate var needsRearange = false
    
    override func layoutSubviews() {
        
        if animator.isRunning { return }
        else if setCardViews().count == 0 { return }
        else if !needsRearange { return }
        
        grid.frame = bounds
        grid.cellCount = setCardViews().count
        let rearrangedCardIndices = 0..<self.setCardViewsThatNeedToBeRearranged.count
        for index in rearrangedCardIndices {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.25,
                delay: 0,
                options: [.allowAnimatedContent],
                animations: {
                    self.setCardViews()[index].frame = self.grid[index]!.inset(by: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
                }
            )
        }
        var delay = 0.25
        for index in self.setCardViewsThatNeedToBeRearranged.count..<setCardViews().count {
            let card = setCardViews()[index]
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: delay,
                options: [.allowAnimatedContent],
                animations: {
                    card.frame = self.grid[index]!.inset(by: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
                },
                completion: { finish in
                    if !self.setCardViews().indices.contains(index) { return }
                    if (card.isFaceUp) { return }
                    UIView.transition(
                        with: card,
                        duration: 0.55,
                        options: [.transitionFlipFromLeft],
                        animations: {
                            card.isFaceUp = true
                    })
                }
            )
            delay += AnimationConstants.dealCardDelay
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        needsRearange = true
    }
    
    fileprivate func fromSetToSetCardView(_ set: [SetCard]) -> [SetCardView] {
        return set.map { SetCardView(frame: frame, setCard: $0) }
    }
    
    fileprivate func setCardViews() -> [SetCardView] {
        return subviews as! [SetCardView]
    }
    
    fileprivate var setCardViewsThatNeedToBeRearranged: [SetCardView] {
        return setCardViews().filter {
            $0.isFaceUp &&
            !cardStartFlyingOutBehavior.contains($0)  &&
            !cardEndFlyingOutBehavior.contains($0)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

extension UIColor {
    static func setCardColor(_ c: SetCardFigureColor) -> UIColor {
        switch c {
        case .blue: return #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case .green: return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        case .red: return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
    }
}

struct SetCardViewBorderColors {
    public static let select = UIColor.blue
    public static let correct = UIColor.green
    public static let mistake = UIColor.red
}

struct AnimationConstants {
    public static let dealCardDelay = 0.15
}
