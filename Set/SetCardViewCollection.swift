//
//  SetView.swift
//  Set
//
//  Created by Вадим on 08.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardViewCollection: UIView {

    private var needAddSet: (()->Void)?
    private var needResetBotMode: (()->Void)?
    
    private var isDeckEmpty: (()->Bool)?
    
    private lazy var grid = Grid(layout: .aspectRatio(6.0/5.0), frame: bounds)

    private var selected = [SetCardView]()
    
    private var score = SetCardGameScoreSystem()
    private var cheat = SetCardGameCheat()
    
    private var isSelectedCardsMakeAMatch: Bool {
        get {
            SetGame.match(set: selected.map { $0.setCard! })
        }
    }
    
    public func setOnScoreChanged(_ callback: @escaping (Int)->Void) {
        score.setOnChangedHandler(callback)
    }
    
    public func setIsDeckEmpty(_ callback: @escaping ()->Bool) {
        isDeckEmpty = callback
    }
    
    public func setAddSet(_ callback: @escaping ()->Void) {
        needAddSet = callback
    }
    
    public func setResetBotMode(_ callback: @escaping ()->Void) {
        needResetBotMode = callback
    }
    
    ///
    // Public API
    ///
    public func cheatSet() -> Bool {
        if isSelectedCardsMakeAMatch {
            respondToMatchedSet(isDeckEmpty?() ?? true)
            return false
        } else {
            guard let matches = cheat.detectSet(in: setCardViews()) else { return false }
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
        needResetBotMode?()
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
            replaceMatchedSetCards(set)
        } else {
            addSetCardViews(fromSetToSetCardView(set))
        }
    }
    
    fileprivate func replaceMatchedSetCards(_ set: [SetCard]) {
        for index in selected.indices {
            selected[index].setNewSetCard(setCard: set[index])
        }
        deselectSelectedSetCardViews()
    }
    
    fileprivate func addSetCardViews(_ newSetCardViews: [SetCardView]) {
        newSetCardViews.forEach {
            $0.addTarget(self, action: #selector(setCardViewHasBeenTouched), for: .touchUpInside)
            $0.backgroundColor = .clear
            $0.contentMode = .redraw
            addSubview($0)
        }
        setNeedsLayout()
    }
    
    fileprivate func respondToMatchedSet(_ deckIsEmpty: Bool) {
        if deckIsEmpty {
            matchIsFoundButDeckIsEmpty()
        } else {
            needAddSet?()
        }
    }
    
    fileprivate func matchIsFoundButDeckIsEmpty() {
        selected.forEach { $0.removeFromSuperview() }
        selected.removeAll()
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
            respondToMatchedSet(isDeckEmpty?() ?? true)
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
    }
    
    @objc public func handleSwipeGestures(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            needAddSet?()
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
    
    override func layoutSubviews() {
        grid.frame = bounds
        grid.cellCount = setCardViews().count
        for index in 0..<grid.cellCount {
            setCardViews()[index].frame = grid[index]!.inset(by: UIEdgeInsets(top: 8.5, left: 3.5, bottom: 8.5, right: 3.5))
        }
    }
    
    fileprivate func fromSetToSetCardView(_ set: [SetCard]) -> [SetCardView] {
        return set.map { SetCardView(frame: frame, setCard: $0) }
    }
    
    fileprivate func setCardViews() -> [SetCardView] {
        return subviews as! [SetCardView]
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
