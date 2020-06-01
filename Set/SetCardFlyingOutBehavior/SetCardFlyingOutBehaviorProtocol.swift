//
//  SetCardFlyingOutBehaviorProtocol.swift
//  Set
//
//  Created by Вадим on 01.06.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

protocol SetCardFlyingOutBehavior {
    
    var viewsInUse: [SetCardView] { get set }
    
    func contains(_ item: UIDynamicItem) -> Bool
}
