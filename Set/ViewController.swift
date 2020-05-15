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
        
    @IBOutlet weak var dealSetButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    @IBOutlet weak var playerOneButton: UIButton!
    @IBOutlet weak var playerTwoButton: UIButton!
    
    @IBOutlet weak var scoreLabelPlayerOne: UILabel!
    @IBOutlet weak var scoreLabelPlayerTwo: UILabel!
    
    @IBOutlet weak var setCardViewCollection: SetCardViewCollection!
    
    @IBAction func dealSet(_ sender: UIButton) {
        addSet()
    }
    
    @IBAction func cheatSet(_ sender: UIButton) {
        if !setCardViewCollection.isTwoPlayerModeEnabled { return }
        setCardViewCollection.cheatSet()
    }
    
    @IBAction func restartGame(_ sender: UIButton) {
        game = SetGame()
        dealSetButton.isEnabled = true
        setCardViewCollection.reset()
        start()
    }
    @IBAction func playerOneTurn(_ sender: UIButton) {
        setCardViewCollection.startPlayerTurn(turn: true)
    }
    
    @IBAction func playerTwoTurn(_ sender: UIButton) {
        setCardViewCollection.startPlayerTurn(turn: false)
    }
    
    @IBOutlet var mainView: UIView!
    
    private func scaleFonts() {
        dealSetButton.titleLabel?.font = scaledFont
        playerOneButton.titleLabel?.font = scaledFont
        playerTwoButton.titleLabel?.font = scaledFont
        cheatButton.titleLabel?.font = scaledFont
        newGameButton.titleLabel?.font = scaledFont
        scoreLabelPlayerOne.font = scaledFont
        scoreLabelPlayerTwo.font = scaledFont
    }
    
    fileprivate func addGestureRecognizersToSetCardViewCollection() {
        let rotationRecognizer = UIRotationGestureRecognizer(target: setCardViewCollection, action: #selector(SetCardViewCollection.handleRotationGestures(gesture:)))
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: setCardViewCollection, action: #selector(SetCardViewCollection.handleSwipeGestures(gesture:)))
        swipeDownRecognizer.direction = .down
        setCardViewCollection.addGestureRecognizer(swipeDownRecognizer)
        setCardViewCollection.addGestureRecognizer(rotationRecognizer)
    }
    
    fileprivate func addTwoPlayerModeCallbacks() {
        setCardViewCollection.setOnScoreChangedPlayerOne(updatePlayerOneScore)
        setCardViewCollection.setOnScoreChangedPlayerTwo(updatePlayerTwoScore)
        setCardViewCollection.setOnGameHasStarted(gameHasStarted)
        setCardViewCollection.setOnPlayerHasHalfTime(playerHasHalfTime)
        setCardViewCollection.setOnNextPlayerTurn(nextPlayerTurn)
        setCardViewCollection.setOnGameHasFinished(gameHasFinished)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizersToSetCardViewCollection()
        addTwoPlayerModeCallbacks()
        scaleFonts()
        start()
    }
    
    private func start() {
        var sets = [SetCard]()
        for _ in 0..<4 {
            sets += game.getSet()!
        }
        setCardViewCollection.initialSetCards(sets)
        setCardViewCollection.setOnScoreChangedPlayerOne(updatePlayerOneScore(score:))
        setCardViewCollection.setIsDeckEmpty(isDeckEmpty)
        setCardViewCollection.setAddSet(addSet)
        dealSetButton.isEnabled = false
    }
    
    fileprivate func updatePlayerOneScore(score: Int) {
        scoreLabelPlayerOne.text = "Score: \(score)"
    }
    
    fileprivate func updatePlayerTwoScore(score: Int) {
        scoreLabelPlayerTwo.text = "Score: \(score)"
    }
    
    fileprivate func playerHasHalfTime(turn: Bool) {
        if turn {
            playerOneButton.setTitleColor(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), for: .normal)
        } else {
            playerTwoButton.setTitleColor(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), for: .normal)
        }
    }
    
    fileprivate func gameHasStarted(turn: Bool) {
        if turn {
            playerOneButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
            playerTwoButton.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        } else {
            playerTwoButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
            playerOneButton.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        }
        playerOneButton.isEnabled = false
        playerTwoButton.isEnabled = false
        setCardViewCollection.enableSetCardViews()
        dealSetButton.isEnabled = true
    }
    
    fileprivate func nextPlayerTurn(turn: Bool) {
        if turn {
            playerTwoButton.setTitleColor(UIColor.systemBlue, for: .normal)
        } else {
            playerOneButton.setTitleColor(UIColor.systemBlue, for: .normal)
        }
        gameHasStarted(turn: turn)
    }
    
    fileprivate func gameHasFinished() {
        playerTwoButton.setTitleColor(UIColor.systemBlue, for: .normal)
        playerOneButton.setTitleColor(UIColor.systemBlue, for: .normal)
        playerOneButton.isEnabled = true
        playerTwoButton.isEnabled = true
        setCardViewCollection.deselectSelected()
        setCardViewCollection.disableSetCardViews()
        dealSetButton.isEnabled = false
    }
    
    private func changeDealButtonState(_ state: Bool) {
        dealSetButton.isEnabled = state
    }
    
    private func addSet() {
        setCardViewCollection.add(set: game.getSet())
        updateDealButtonState()
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
        mainView.bounds.height * 0.0325
    }
    fileprivate var scaledFont: UIFont {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(controlsFontSizeToMainViewBoundsHeight)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        return font
    }
}
