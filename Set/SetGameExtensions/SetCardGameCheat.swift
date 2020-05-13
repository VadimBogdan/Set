//
//  MatchDetector.swift
//  Set
//
//  Created by Вадим on 25.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct SetCardGameCheat
{
    public mutating func detectSet(in setCardViews: [SetCardView]) -> [[SetCardView]]?
    {
        return fromCombinationsToMatches(getCombinations(setCardViews))
    }
    
    
    fileprivate func fromCombinationsToMatches(_ combinations: [[SetCardView]]) -> [[SetCardView]]? {
        var matches = [[SetCardView]]()
        for i in combinations.indices {
            let j = 0
            if SetGame.match(set: [combinations[i][j].setCard!,combinations[i][j+1].setCard!,combinations[i][j+2].setCard!]) {
                matches += [[combinations[i][j],combinations[i][j+1],combinations[i][j+2]]]
            }
        }
        
        removeDuplicates(&matches)
        return matches.count == 0 ? nil : matches
    }
    
    fileprivate func removeDuplicates(_ matches: inout [[SetCardView]]) {
        var suffixLength = matches.count >= 2 ? 1 : 0
        var countBeforeRemovingCycle = matches.count
        matches.forEach {
            match in match.forEach {
                matchedCard in matches.suffix(from: suffixLength).forEach {
                    removeDuplicate($0, matchedCard, &matches)
                }
            }
            let countOfRemoved = countBeforeRemovingCycle - matches.count
            countBeforeRemovingCycle = matches.count
            suffixLength += (countOfRemoved == 0) ? (suffixLength+1 < matches.count) ? 1 : 0 : 0
        }
    }
    
    fileprivate func removeDuplicate(_ duplicate: [SetCardView], _ matchedCard: SetCardView, _ matches: inout [[SetCardView]]) {
        if duplicate.contains(matchedCard) {
            matches.remove(duplicate)
        }
    }
    
    fileprivate func getCombinations(_ setCardViews: [SetCardView]) -> [[SetCardView]]  {
        return doCombinations(source: setCardViews, takenBy: 3)
    }
    
    // Calculate the unique combinations of elements in an array
    // taken some number at a time when no element is allowed to repeat
    // https://stackoverflow.com/a/25879655
    fileprivate func doCombinations<T>(source: [T], takenBy : Int) -> [[T]] {
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
            return source.map { [$0] }
        }

        var result : [[T]] = []

        let rest = Array(source.suffix(from: 1))
        let subCombos = doCombinations(source: rest, takenBy: takenBy - 1)
        result += subCombos.map { [source[0]] + $0 }
        result += doCombinations(source: rest, takenBy: takenBy)
        return result
    }
}
