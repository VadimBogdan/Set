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
    
    private var isDeckEmpty: (()->Bool)?
    
    private lazy var grid = Grid(layout: .aspectRatio(6.0/5.0), frame: bounds)

    private var selected = [SetCardView]()
    
    // private var score = SetCardGameScoreSystem()
    private var cheat = SetCardGameCheat()
    
    private var twoPlayerMode = SetGameTwoPlayerMode()
    
    // for two player mode callbacks
    
    public func setOnPlayerHasHalfTime(_ callback: @escaping (Bool)->Void) {
        twoPlayerMode.setOnPlayerHasHalfTime(callback)
    }
    
    public func setOnNextPlayerTurn(_ callback: @escaping (Bool)->Void) {
        twoPlayerMode.setOnNextPlayerTurn(callback)
    }
    
    public func setOnGameHasStarted(_ callback: @escaping (Bool)->Void) {
        twoPlayerMode.setOnGameHasStarted(callback)
    }
    
    public func setOnGameHasFinished(_ callback: @escaping ()->Void) {
        twoPlayerMode.setOnGameHasFinished(callback)
    }
    
    public func setOnScoreChangedPlayerOne(_ callback: @escaping (Int)->Void) {
        twoPlayerMode.setOnScoreChangedPlayerOne(callback)
    }
    
    public func setOnScoreChangedPlayerTwo(_ callback: @escaping (Int)->Void) {
       twoPlayerMode.setOnScoreChangedPlayerTwo(callback)
    }
    
    public func setIsDeckEmpty(_ callback: @escaping ()->Bool) {
        isDeckEmpty = callback
    }
    
    public func setAddSet(_ callback: @escaping ()->Void) {
        needAddSet = callback
    }
    
    private var isSelectedCardsMakeAMatch: Bool {
        get {
            SetGame.match(set: selected.map { $0.setCard! })
        }
    }
    
    ///
    // Public API
    
    public var isTwoPlayerModeEnabled: Bool {
        return twoPlayerMode.isEnabled
    }
    ///
    public func cheatSet() {
        if isSelectedCardsMakeAMatch {
            respondToMatchedSet(isDeckEmpty?() ?? true)
        } else {
            guard let matches = cheat.detectSet(in: setCardViews()) else { return }
            deselectSelectedSetCardViews()
            matches[0].forEach
            {
                setCardViewHasBeenTouched(setCardView: $0)
            }
        }
    }
    
    public func add(set: [SetCard]?) {
        guard let set = set else { return }
        assert(setCardViews().count < 81, "Number of set cards cannot be larger than 81.")
        doPenaltyIfSomeMatchesAvailable()
        updateSubviews(set)
    }
    
    // true - playerOne, false - playerTwo
    public func startPlayerTurn(turn: Bool) {
        twoPlayerMode.start(turn: turn)
        enableSetCardViews()
    }
    
    public func initialSetCards(_ setCards: [SetCard]) {
        updateSubviews(setCards)
    }
    
    public func reset() {
        setCardViews().forEach { $0.removeFromSuperview() }
        selected.removeAll()
        twoPlayerMode.reset()
    }
    
    public func deselectSelected() {
        if isSelectedCardsMakeAMatch {
            respondToMatchedSet(isDeckEmpty?() ?? true)
        } else {
            deselectSelectedSetCardViews()
        }
    }
    
    public func enableSetCardViews() {
        setCardViews().forEach { $0.isEnabled = true }
    }
    
    public func disableSetCardViews() {
        setCardViews().forEach { $0.isEnabled = false }
    }
    
    fileprivate func doPenaltyIfSomeMatchesAvailable() {
        /// Penalty for not matched matches on screen
        if selected.count != 3 {
            if let matches = cheat.detectSet(in: setCardViews()) {
                twoPlayerMode.updateScore(-matches.count)
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
            $0.isEnabled = false
            addSubview($0)
        }
        setNeedsLayout()
    }
    
    fileprivate func respondToMatchedSet(_ deckIsEmpty: Bool) {
        if deckIsEmpty {
            matchIsFoundButDeckIsEmpty()
        } else {
            needAddSet?()
            twoPlayerMode.playerDealedSetCards()
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
        twoPlayerMode.updateScore(.deselection)
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
        if !twoPlayerMode.isEnabled { return }
        if gesture.direction == .down {
            needAddSet?()
            twoPlayerMode.playerDealedSetCards()
        }
    }
    
    @objc public func handleRotationGestures(gesture: UIRotationGestureRecognizer) {
        if !twoPlayerMode.isEnabled { return }
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
            twoPlayerMode.updateScoreMatched(subviews.count)
        } else {
            twoPlayerMode.updateScoreNotMatched(setCardViews().count)
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
