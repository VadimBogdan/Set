//
//  MatchDetector.swift
//  Set
//
//  Created by Вадим on 25.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation
import UIKit

struct SetCardGameCheat
{
    private var combinations = [[(UIButton,SetCard)]]()
    ///
    public mutating func detectSet(in buttonCardMap: [UIButton:SetCard]) -> [UIButton:SetCard]?
    {
        combinations = doCombinations(source: Array(buttonCardMap), takenBy: 3)
        return getMatchedSet(combinations: combinations)
    }
    
    private func getMatchedSet(combinations: [[(UIButton,SetCard)]]) -> [UIButton:SetCard]? {
        var matches = [UIButton:SetCard]()
        for i in combinations.indices {
            let j = 0
            if SetGame.match(set: [combinations[i][j].1,combinations[i][j+1].1,combinations[i][j+2].1]) {
                matches[combinations[i][j].0] = combinations[i][j].1
                matches[combinations[i][j+1].0] = combinations[i][j+1].1
                matches[combinations[i][j+2].0] = combinations[i][j+2].1
                break;
            }
        }
        return matches.count == 0 ? nil : matches
    }

    // Calculate the unique combinations of elements in an array
    // taken some number at a time when no element is allowed to repeat
    // https://stackoverflow.com/a/25879655
    private func doCombinations<T,K>(source: [(T,K)], takenBy : Int) -> [[(T,K)]] {
        if(source.count == takenBy) {
            return [source]
        }

        if(source.isEmpty) {
            return []
        }

        if(takenBy == 0) {
            return []
        }

        if(takenBy == 1) {
            return source.map { [($0.0,$0.1)] }
        }

        var result : [[(T,K)]] = []

        let rest = Array(source.suffix(from: 1))
        let subCombos = doCombinations(source: rest, takenBy: takenBy - 1)
        result += subCombos.map { [source[0]] + $0 }
        result += doCombinations(source: rest, takenBy: takenBy)
        return result
    }
}
