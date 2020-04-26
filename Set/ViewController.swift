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
    private var buttonsCards = [UIButton:SetCard]()
    private var selectedButtonCards = [UIButton:SetCard]()
    /// Used to save currently selected buttons when cheat used
    private var selectedButtonCardsCheat = [UIButton:SetCard]()
    private var matchedButtonCards = [UIButton:SetCard]()
    private var freeButtonsIndices = [Int]()
    // 30 seconds good; > bad
    private var timeRange = Date()
    // Computer mode
    private var computerMode: ComputerMode?
    
    private var score = 0 {
        didSet {
            updateScoreLabel()
        }
    }
    
    private var isMatched: Bool {
        get {
            SetGame.match(set: Array(selectedButtonCards.values))
        }
    }
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var computerModeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func activateComputerMode(_ sender: UIButton) {
        computerMode = ComputerMode { t in
            if self.cheat() {
                self.computerModeButton.setTitle("😂", for: .disabled)
            } else {
                self.computerModeButton.setTitle("😢", for: .disabled)
            }
            
        }
        computerMode?.setAnticipation { t in self.computerModeButton.setTitle("😁", for: .disabled) }
        computerMode?.setThink { self.computerModeButton.setTitle("🤔", for: .disabled) }
        computerModeButton.isEnabled = false
    }
    
    @IBAction func dealSetUI(_ sender: UIButton) {
        /// Penalty for not matched matches on screen
        if selectedButtonCards.count != 3 {
            if let matches = Cheat.detectSet(in: buttonsCards) {
                score -= matches.count * 1
            }
        }
        selectedIsMatchedDoDeal()
    }
    
    @IBAction func cheatSet(_ sender: UIButton) {
        if isMatched {
            selectedIsMatchedDoDeal()
        } else {
            cheat()
        }
    }
    @discardableResult
    private func cheat() -> Bool {
        if let matches = Cheat.detectSet(in: buttonsCards) {
            if selectedButtonCards.count == 3 {
                selectedButtonCards.forEach({ deselect(button: $0.key) })
            } else if selectedButtonCardsCheat.count == 0 {
                selectedButtonCardsCheat = selectedButtonCards
            }
            selectedButtonCards.removeAll()
            let buttons = Array(matches.keys)
            for i in 0..<3 {
                selectedButtonCards[buttons[i]] = buttonsCards[buttons[i]]
            }
            selectedButtonCards.forEach({ select(button: $0.key, with: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)) })
            return true
        }
        return false
    }
    
    @IBAction func startNewGame(_ sender: UIButton) {
        game = SetGame()
        score = 0
        buttons.forEach({ deselect(button: $0) })
        buttons.forEach({ $0.setTitle(nil, for: .normal); $0.setAttributedTitle(nil, for: .normal) })
        computerModeButton.setTitle("VS", for: .normal)
        selectedButtonCards.removeAll()
        selectedButtonCardsCheat.removeAll()
        matchedButtonCards.removeAll()
        freeButtonsIndices.removeAll()
        buttonsCards.removeAll()
        dealButton.isEnabled = true
        computerModeButton.isEnabled = true
        start()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if buttonsCards[sender] == nil {
            return
        }
        
        if selectedButtonCards.count == 3 {
            if isMatched {
                /// Don't select matched cards until they're replaced.
                if selectedButtonCards[sender] != nil { return }
                selectedIsMatchedDoDeal()
            } else {
                selectedButtonCards.forEach({ deselect(button: $0.key) })
                selectedButtonCards.removeAll()
            }
        }
        
        if selectedButtonCardsCheat.count != 0 {
            fixCheat()
            selectedButtonCards = selectedButtonCardsCheat
            selectedButtonCardsCheat.removeAll()
        }
        
        if selectedButtonCards[sender] != nil {
            score -= 1
            selectedButtonCards.removeValue(forKey: sender)
            deselect(button: sender)
        } else {
            selectedButtonCards[sender] = buttonsCards[sender]
            select(button: sender, with: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        }
        if selectedButtonCards.count == 3 {
            if isMatched {
                if Date().timeIntervalSince(timeRange) < 30.0 {
                    if freeButtonsIndices.count <= 6 {
                        score += 3
                    } else {
                        score += 6
                    }
                } else {
                    if freeButtonsIndices.count <= 6 {
                        score += 1
                    } else {
                        score += 3
                    }
                }
                dealButton.isEnabled = true
                selectedButtonCards.forEach({ select(button: $0.key, with: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)) })
            } else {
                if Date().timeIntervalSince(timeRange) < 30.0 {
                    if freeButtonsIndices.count <= 6 {
                        score -= 4
                    } else {
                        score -= 2
                    }
                } else {
                    if freeButtonsIndices.count <= 6 {
                        score -= 8
                    } else {
                        score -= 5
                    }
                }
                selectedButtonCards.forEach({ select(button: $0.key, with: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)) })
            }
        }
    }
    
    private func start() {
        freeButtonsIndices.append(contentsOf: buttons.indices)
        buttons.forEach({ $0.backgroundColor = UIColor.white} )
        for _ in 0..<4 {
            if let card = game.getSet() {
                for i in 0..<3 {
                    let buttonIndex = freeButtonsIndices.randomElement()!
                    let arrayIndex = freeButtonsIndices.firstIndex(of: buttonIndex)!
                    freeButtonsIndices.remove(at: arrayIndex)
                    map(button: buttons[buttonIndex], with: card[i])
                }
            }
        }
        // score based on time
        timeRange = Date.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
        timeRange = Date()
    }
    
    private func selectedIsMatchedDoDeal() {
        selectedButtonCards.forEach({ deselect(button: $0.key) })
        matchedButtonCards = selectedButtonCards
        selectedButtonCards.removeAll()
        dealSet()
    }
    
    private func dealSet() {
        if matchedButtonCards.count != 0 { game.updateMatched(set: Array(matchedButtonCards.values)) }
        if let set = game.getSet() {
            for card in set {
                if matchedButtonCards.count > 0 {
                    let rButtonCard = matchedButtonCards.randomElement()!
                    matchedButtonCards.removeValue(forKey: rButtonCard.key)
                    map(button: rButtonCard.key, with: card)
                } else if freeButtonsIndices.count > 0 {
                    let index = freeButtonsIndices.randomElement()!
                    freeButtonsIndices.remove(index)
                    map(button: buttons[index], with: card)
                }
            }
            if game.deck.count == 0 || freeButtonsIndices.count == 0 {
                dealButton.isEnabled = false
            }
        } else {
            dealButton.isEnabled = false
            for buttonCard in matchedButtonCards {
                buttonsCards.removeValue(forKey: buttonCard.key)
                hide(button: buttonCard.key)
            }
        }
        matchedButtonCards.removeAll()
        /// Computer mode starts
        if computerMode != nil { computerMode?.think() }
    }
    
    private func fixCheat() {
        selectedButtonCardsCheat.forEach({
            if buttonsCards[$0.key] != $0.value {
            selectedButtonCardsCheat.removeValue(forKey: $0.key)
            }
        })
    }
    
    private func hide(button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        button.setAttributedTitle(nil, for: .normal)
        button.setTitle(nil, for: .normal)
        button.layer.borderWidth = 0.0
        button.layer.cornerRadius = 0.0
        button.layer.borderColor = UIColor.white.cgColor
        button.isEnabled = false
    }
    
    private func select(button: UIButton, with colour: UIColor) {
        button.layer.borderWidth = 3.0
        button.layer.cornerRadius = 8.0
        button.layer.borderColor = colour.cgColor
    }
    
    private func deselect(button: UIButton) {
        button.layer.borderWidth = 0.0
        button.layer.cornerRadius = 0.0
        button.layer.borderColor = UIColor.white.cgColor
    }

    // Mapping UIButton to SetCard
    private func map(button: UIButton, with card: SetCard) {
        buttonsCards[button] = card
        let cardColor = symbolColour[card.color]!
        let symbol = symbolString[card.symbol]!.dupe(by: UInt(card.number.rawValue))
        let keys: [NSAttributedString.Key:Any] = [
            .strokeWidth     : symbolStrokeWidth[card.shading]!,
            .foregroundColor : cardColor.shade(with: card.shading),
            .strokeColor     : cardColor
        ]
        button.setAttributedTitle(NSAttributedString(string: symbol, attributes: keys), for: .normal)
    }
        
    private let symbolColour: [CardColor:UIColor] = [
        CardColor.blue      :  #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),
        CardColor.green     :  #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1),
        CardColor.red       :  #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    ]
    
    private let symbolString: [CardSymbol:String] = [
        CardSymbol.circle   :  "●",
        CardSymbol.square   :  "■",
        CardSymbol.triangle :  "▲"
    ]
    
    private let symbolStrokeWidth: [CardShading:Double] = [
        CardShading.solid   : -5.0,
        CardShading.open    :  5.0,
        CardShading.striped :  0.0
    ]
}

extension UIColor {
    func shade(with shading: CardShading) -> UIColor {
        switch shading {
            case .open: return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            case .solid: return self.withAlphaComponent(1.0)
            case .striped: return self.withAlphaComponent(0.35)
        }
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension String {
    func dupe(by number: UInt) -> String {
        assert(number != 0)
        var temp = self
        for _ in 1..<number { temp += self }
        return temp
    }
}
