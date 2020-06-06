//
//  ViewController.swift
//  Concentration
//
//  Created by Вадим on 01.06.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {
    private let themes: [String:(Emoji: String, Background: UIColor, CardBack: UIColor)] = [
        "sport"     : (Emoji: "🏈🏀⚾️🥎⚽️🎾🎱🏐", Background: #colorLiteral(red: 0.8247443866, green: 0.9960500161, blue: 1, alpha: 1), CardBack: #colorLiteral(red: 0.6115363261, green: 0.4883482626, blue: 0.5769907858, alpha: 1)),
        "face"      : (Emoji: "😀😃😇😂😘🙃😋🤪", Background: #colorLiteral(red: 0.6679978967, green: 0.6615128252, blue: 0.5876712883, alpha: 1), CardBack: #colorLiteral(red: 1, green: 0.580126236, blue: 0.01286631583, alpha: 1)),
        "animal"    : (Emoji: "🐶🐵🐷🦁🐮🐨🦊🐰", Background: #colorLiteral(red: 0.5102706931, green: 0.9768045545, blue: 0.5775219063, alpha: 1), CardBack: #colorLiteral(red: 0.5175958016, green: 0.4076852984, blue: 0.280905613, alpha: 1)),
        "food"       : (Emoji: "🍏🍋🍆🥥🥦🧅🌽🧄", Background: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), CardBack: #colorLiteral(red: 0.4082181874, green: 0.5323388773, blue: 0.05528809654, alpha: 1)),
        "technology" : (Emoji: "⌚️📱🖥💿🎥📺💾🖨", Background: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), CardBack: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        "halloween"  : (Emoji: "🦇😱🙀😈👻🍭🎃🍬", Background: #colorLiteral(red: 0.6781012056, green: 0.4917565874, blue: 0.4612182636, alpha: 1), CardBack: #colorLiteral(red: 0.3178377408, green: 0.09699456698, blue: 0.572791085, alpha: 1))
    ]
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    @IBOutlet weak var technology: UIButton!
    @IBOutlet weak var halloween: UIButton!
    @IBOutlet weak var sport: UIButton!
    @IBOutlet weak var food: UIButton!
    @IBOutlet weak var face: UIButton!
    @IBOutlet weak var animal: UIButton!
    
    
    @IBAction func chooseTheme(_ sender: UIButton) {
        performSegue(withIdentifier: "Choose Theme", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let cvc = segue.destination as? ConcentrationViewController {
            if segue.identifier == "Choose Theme" {
                let button = sender as! UIButton
                let title: String
                switch button {
                case technology:
                    title = "technology"
                    cvc.theme = themes[title]!
                case halloween:
                    title = "halloween"
                    cvc.theme = themes["halloween"]!
                case sport:
                    title = "sport"
                    cvc.theme = themes["sport"]!
                case food:
                    title = "food"
                    cvc.theme = themes["food"]!
                case face:
                    title = "face"
                    cvc.theme = themes["face"]!
                case animal:
                    title = "animal"
                    cvc.theme = themes["animal"]!
                default:
                    title = "face"
                    cvc.theme = themes["face"]!
                }
           }
            cvc.title = title
       }
    }
}
