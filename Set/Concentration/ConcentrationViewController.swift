//
//  ViewController.swift
//  Concentration
//
//  Created by Вадим on 10.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController
{
    fileprivate lazy var game: Concentration =
        Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    fileprivate var numberOfPairsOfCards: Int {
        return (cardButtons.count+1) / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        for card in cardButtons {
            card.backgroundColor = cardBackColor
        }
    }
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
        emojiChoices = theme.Emoji
        // new card array
        emoji = [Card:String]()
        updateViewFromModel()
    }
    
    private func updateScoreLabel(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func updateFlipCountLabel(_ flipCount: Int = 0) {
//        let attributes: [NSAttributedString.Key:Any] = [
//            .strokeWidth : 3.0,
//            .strokeColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
//        ]
//        let attributedString = NSAttributedString(string: "Flips: \(flipCount)", attributes: attributes)
//
//        flipCountLabel.attributedText = attributedString
        flipCountLabel.text = "Flips: \(flipCount)"
    }
    
    private func updateViewFromModel() {
        updateScoreLabel(game.score)
        updateFlipCountLabel(game.flipCount)
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: .normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: .normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : cardBackColor
            }
        }
    }
    
    private var emojiChoices = "😀😃😇😂😘🙃😋🤪"
    private var backgroundColor: UIColor = #colorLiteral(red: 0.6679978967, green: 0.6615128252, blue: 0.5876712883, alpha: 1)
    private var cardBackColor: UIColor = #colorLiteral(red: 1, green: 0.580126236, blue: 0.01286631583, alpha: 1)
    
    private var emoji = [Card:String]()
    
    public var theme: (Emoji: String, Background: UIColor, CardBack: UIColor) =
        ("😀😃😇😂😘🙃😋🤪", #colorLiteral(red: 0.6679978967, green: 0.6615128252, blue: 0.5876712883, alpha: 1), #colorLiteral(red: 1, green: 0.580126236, blue: 0.01286631583, alpha: 1)) {
        didSet {
            emojiChoices = theme.Emoji
            backgroundColor = theme.Background
            cardBackColor = theme.CardBack
        }
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
}
