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
    
    // play vs your iPhone/iPad (bot)
    private var gameAgainstPhoneMode: SetCardGamePhoneMode?
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var botModeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    @IBOutlet weak var setCardViewCollection: SetCardViewCollection!
    
    @IBAction func activateBotMode(_ sender: UIButton) {
        gameAgainstPhoneMode = SetCardGamePhoneMode { _ in
            if self.setCardViewCollection.cheatSet() {
                self.botModeButton.setTitle("😂", for: .disabled)
            } else {
                self.botModeButton.setTitle("😢", for: .disabled)
            }
        }
        gameAgainstPhoneMode?.setAnticipation { _ in self.botModeButton.setTitle("😁", for: .disabled) }
        gameAgainstPhoneMode?.setThink { self.botModeButton.setTitle("🤔", for: .disabled) }
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
        dealButton.titleLabel?.alpha = 1.0
        dealButton.alpha = 1.0
        botModeButton.isEnabled = true
        gameAgainstPhoneMode?.stop()
        setCardViewCollection.reset()
        start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizersToSetCardViewCollection()
        scaleFonts()
        start()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        scaleFonts()
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
            setCardViewCollection(addSetTo: setCardViewCollection)
        }
    }
    
    func setCardViewCollection(addSetTo: SetCardViewCollection) {
        addSetTo.add(set: game.getSet())
        if setCardViewCollection(isDeckEmptyFrom: addSetTo) {
            dealButton.isEnabled = false
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.35,
                delay: 0,
                options: [],
                animations: {
                    self.dealButton.titleLabel!.alpha = 0.0
                },
                completion: { finish in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.40,
                        delay: 0.0,
                        options: [],
                        animations: {
                            self.dealButton.alpha = 0.0
                    })
                }
            )
        }
    }
    
    func setCardViewCollection(resetBotModeFrom: SetCardViewCollection) {
        gameAgainstPhoneMode?.stop()
        gameAgainstPhoneMode?.thinking()
    }
    
    func setCardViewCollection(currentScore: Int, _ from: SetCardViewCollection) {
        scoreLabel.text = "Score: \(currentScore)"
    }
    
    func setCardViewCollection(isDeckEmptyFrom: SetCardViewCollection) -> Bool {
        return game.deck.count == 0
    }
    
    func setCardViewCollection(deckFrameFor: SetCardViewCollection) -> CGRect {
        return dealButton.convert(dealButton.bounds.inset(by: UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1)), to: deckFrameFor)
    }
    
    func setCardViewCollection(discardPileFrameFor: SetCardViewCollection) -> CGRect {
        return scoreLabel.convert(scoreLabel.bounds.inset(by: UIEdgeInsets(top: -15, left: -25, bottom: -15, right: -25)), to: discardPileFrameFor.superview!)
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
        view.bounds.height * 0.025
    }
    fileprivate var controlsFontSizeToMainViewBoundsWidth: CGFloat {
        view.bounds.width * 0.025
    }
    fileprivate var scaledFont: UIFont {
        var font: UIFont
        if view.bounds.height < view.bounds.width {
            font = UIFont.preferredFont(forTextStyle: .body).withSize(controlsFontSizeToMainViewBoundsWidth)
        } else {
            font = UIFont.preferredFont(forTextStyle: .body).withSize(controlsFontSizeToMainViewBoundsHeight)

        }
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
