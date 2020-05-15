//
//  ViewController.swift
//  Set
//
//  Created by Вадим on 22.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var game = SetGame()
    
    // Computer mode
    private var botMode: SetCardGameBotMode?
    
    @IBOutlet weak var dealSetButton: UIButton!
    @IBOutlet weak var botModeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var setCardViewCollection: SetCardViewCollection!
    
    @IBAction func activateBotMode(_ sender: UIButton) {
        botMode = SetCardGameBotMode { [unowned self] _ in
            if self.setCardViewCollection.cheatSet() {
                self.botModeButton.setTitle("😂", for: .disabled)
            } else {
                self.botModeButton.setTitle("😢", for: .disabled)
            }
        }
        botMode?.setAnticipation { _ in self.botModeButton.setTitle("😁", for: .disabled) }
        botMode?.setThink { self.botModeButton.setTitle("🤔", for: .disabled) }
        botModeThink()
        botModeButton.isEnabled = false
    }
    
    @IBAction func dealSet(_ sender: UIButton) {
        addSet()
    }
    
    @IBAction func cheatSet(_ sender: UIButton) {
       _ = setCardViewCollection.cheatSet()
    }
    
    @IBAction func restartGame(_ sender: UIButton) {
        game = SetGame()
        botModeButton.setTitle("Bot", for: .normal)
        dealSetButton.isEnabled = true
        botModeButton.isEnabled = true
        botMode?.stop()
        setCardViewCollection.reset()
        start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizersToSetCardViewCollection()
        scaleFonts()
        start()
    }

    private func scaleFonts() {
        dealSetButton.titleLabel?.font = scaledFont
        newGameButton.titleLabel?.font = scaledFont
        botModeButton.titleLabel?.font = scaledFont
        cheatButton.titleLabel?.font = scaledFont
        scoreLabel.font = scaledFont
    }

    fileprivate func addGestureRecognizersToSetCardViewCollection() {
        let rotationRecognizer = UIRotationGestureRecognizer(target: setCardViewCollection, action: #selector(SetCardViewCollection.handleRotationGestures(gesture:)))
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: setCardViewCollection, action: #selector(SetCardViewCollection.handleSwipeGestures(gesture:)))
        swipeDownRecognizer.direction = .down
        setCardViewCollection.addGestureRecognizer(swipeDownRecognizer)
        setCardViewCollection.addGestureRecognizer(rotationRecognizer)
    }
    
    private func start() {
        var sets = [SetCard]()
        for _ in 0..<4 {
            sets += game.getSet()!
        }
        setCardViewCollection.initialSetCards(sets)
        setCardViewCollection.setOnScoreChanged(updateScoreLabel(score:))
        setCardViewCollection.setIsDeckEmpty(isDeckEmpty)
        setCardViewCollection.setResetBotMode(botModeThink)
        setCardViewCollection.setAddSet(addSet)
    }
    
    private func updateScoreLabel(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func changeDealButtonState(_ state: Bool) {
        dealSetButton.isEnabled = state
    }
    
    private func addSet() {
        setCardViewCollection.add(set: game.getSet())
        updateDealButtonState()
    }
    
    private func botModeThink() {
        botMode?.stop()
        botMode?.thinking()
    }
    
    private func updateDealButtonState() {
        if isDeckEmpty() {
            dealSetButton.isEnabled = !isDeckEmpty()
        }
    }
    
    private func isDeckEmpty() -> Bool {
        return game.deck.count == 0
    }
}
extension Array where Element: Equatable {
    mutating func remove(_ object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension ViewController {
    fileprivate var controlsFontSizeToMainViewBoundsHeight: CGFloat {
        mainView.bounds.height * 0.04
    }
    fileprivate var scaledFont: UIFont {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(controlsFontSizeToMainViewBoundsHeight)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        return font
    }
}
