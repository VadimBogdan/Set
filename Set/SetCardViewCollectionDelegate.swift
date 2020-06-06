//
//  SetCardViewCollectionDelegate.swift
//  Set
//
//  Created by Вадим on 27.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

protocol SetCardViewCollectionDelegate {
    func setCardViewCollection(addSetTo: SetCardViewCollection)
    func setCardViewCollection(resetBotModeFrom: SetCardViewCollection)
    func setCardViewCollection(currentScore: Int, _ from: SetCardViewCollection)
    func setCardViewCollection(isDeckEmptyFrom: SetCardViewCollection) -> Bool
    func setCardViewCollection(deckFrameFor: SetCardViewCollection) -> CGRect
    func setCardViewCollection(discardPileFrameFor: SetCardViewCollection) -> CGRect
}
