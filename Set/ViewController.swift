//
//  ViewController.swift
//  Set
//
//  Created by Вадим on 22.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardGameViewController: UIViewController, SetCardViewCollectionDelegate {
    
    private var game = SetGame()
    
    // Play vs iPhone (bot)
    private var botMode: SetCardGameBotMode?
    
    @IBOutlet weak var dealButton: UIButton! {
        didSet {
            dealButton.contentEdgeInsets  = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        }
    }
    @IBOutlet weak var botModeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var setCardViewCollection: SetCardViewCollection!
    
    @IBAction func activateBotMode(_ sender: UIButton) {
        botMode = SetCardGameBotMode { _ in
            if self.setCardViewCollection.cheatSet() {
                self.botModeButton.setTitle("😂", for: .disabled)
            } else {
                self.botModeButton.setTitle("😢", for: .disabled)
            }
        }
        botMode?.setAnticipation { _ in self.botModeButton.setTitle("😁", for: .disabled) }
        botMode?.setThink { self.botModeButton.setTitle("🤔", for: .disabled) }
        setCardViewCollection(resetBotModeFrom: setCardViewCollection)
        botModeButton.isEnabled = false
    }
    
    @IBAction func dealSet(_ sender: UIButton) {
        setCardViewCollection(addSetTo: setCardViewCollection)
    }
    
    @IBAction func cheatSet(_ sender: UIButton) {
       _ = setCardViewCollection.cheatSet()
    }
    
    @IBAction func restartGame(_ sender: UIButton) {
        game = SetGame()
        botModeButton.setTitle("Bot", for: .normal)
        dealButton.isEnabled = true
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
        dealButton.titleLabel?.font = scaledFont
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
        setCardViewCollection.delegate = self
        (1...4).forEach { _ in
            setCardViewCollection.add(set: game.getSet())
        }
    }
    
    func setCardViewCollection(addSetTo: SetCardViewCollection) {
        addSetTo.add(set: game.getSet())
        if setCardViewCollection(isDeckEmptyFrom: addSetTo) {
            dealButton.isEnabled = !setCardViewCollection(isDeckEmptyFrom: addSetTo)
        }
    }
    
    func setCardViewCollection(resetBotModeFrom: SetCardViewCollection) {
        botMode?.stop()
        botMode?.thinking()
    }
    
    func setCardViewCollection(currentScore: Int, _ from: SetCardViewCollection) {
        scoreLabel.text = "Score: \(currentScore)"
    }
    
    func setCardViewCollection(isDeckEmptyFrom: SetCardViewCollection) -> Bool {
        return game.deck.count == 0
    }
    func setCardViewCollection(deckFrameFor: SetCardViewCollection) -> CGRect {
        return dealButton.frame
    }

}
extension Array where Element: Equatable {
    mutating func remove(_ object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension SetCardGameViewController {
    fileprivate var controlsFontSizeToMainViewBoundsHeight: CGFloat {
        mainView.bounds.height * 0.0325
    }
    fileprivate var scaledFont: UIFont {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(controlsFontSizeToMainViewBoundsHeight)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        return font
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
