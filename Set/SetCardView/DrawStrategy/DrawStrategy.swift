//
//  DrawStrategy.swift
//  Set
//
//  Created by Вадим on 11.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation
import UIKit

protocol DrawLayoutOfSetCardFigureStrategy {
    var bounds: CGRect { get }
    var count: SetCardCountOfFigures { get }
    var setCard: SetCard { get }
    var figureDrawer: FigureDrawer { get }
    var shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)? { get }
    mutating func draw()
    
    init(_ bounds: CGRect, setCard: SetCard, shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?)
}

struct DrawOnXAxis: DrawLayoutOfSetCardFigureStrategy {
    var bounds: CGRect
    var setCard: SetCard
    var count: SetCardCountOfFigures
    var figureDrawer: FigureDrawer
    var shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?
    
    init(_ bounds: CGRect, setCard: SetCard, shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?) {
        self.bounds = bounds
        self.setCard = setCard
        self.shadingDrawer = shadingDrawer
        count = setCard.count
        figureDrawer = FigureDrawer(setCard: setCard)
    }
    
    mutating func draw() {
        switch count {
        case .one:
            figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
        case .two:
           // Variant 2:
           // fBounds = bounds.inset(by: .init(top: bounds.height*0.5, left: 0, bottom: 0, right: 0))
           // fBounds = bounds.inset(by: .init(top: 0, left: 0, bottom: bounds.height*0.5, right: 0))
           // Variant 1:
           bounds.insetBoundsHeight(by: 2)
           bounds.origin.translateBy(y: bounds.height*0.5)
           figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(y: -bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
        case .three:
           bounds.insetBoundsHeight(by: 3)
           bounds.origin.translateBy(y: bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(y: -bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(y: -bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: nil, shadingDrawer: shadingDrawer)
        }
    }
}

struct DrawOnYAxis: DrawLayoutOfSetCardFigureStrategy {
    var bounds: CGRect
    var setCard: SetCard
    var count: SetCardCountOfFigures
    var figureDrawer: FigureDrawer
    var shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?
    
    init(_ bounds: CGRect, setCard: SetCard, shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?) {
        self.bounds = bounds
        self.setCard = setCard
        self.shadingDrawer = shadingDrawer
        count = setCard.count
        figureDrawer = FigureDrawer(setCard: setCard)
    }
    
    fileprivate var affineTransformations: (CGRect, UIBezierPath)->Void {
        { (bounds: CGRect, path:UIBezierPath)->Void in
            let c = bounds.width/bounds.height
            path.apply(CGAffineTransform(scaleX: 1, y: c))
            path.apply(CGAffineTransform(rotationAngle: .pi/2))
            path.apply(CGAffineTransform(translationX: bounds.width*1.05, y: bounds.height*((1-c)*0.5)))
        }
    }

   mutating func draw() {
        switch count {
        case .one:
            figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
        case .two:
           // Variant 2:
           // fBounds = bounds.inset(by: .init(top: bounds.height*0.5, left: 0, bottom: 0, right: 0))
           // fBounds = bounds.inset(by: .init(top: 0, left: 0, bottom: bounds.height*0.5, right: 0))
           // Variant 1:
           bounds.insetBoundsHeight(by: 2)
           bounds.origin.translateBy(y: -bounds.height*0.5)
           figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(x: bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
        case .three:
           bounds.insetBoundsHeight(by: 3)
           bounds.origin.translateBy(y: -bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(x: bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
           bounds.origin.translateBy(x: bounds.height)
           figureDrawer.draw(in: bounds, affineTransformations: affineTransformations, shadingDrawer: shadingDrawer)
        }
    }
}

extension CGRect {
    mutating func insetBoundsHeight(by multiplier: Int) {
        switch multiplier {
        case 2:
            self = self.insetBy(dx: 0, dy: self.height*0.25)
        case 3:
            self = self.insetBy(dx: 0, dy: (1 - 0.33) * 0.5 * self.height)
        default:
            break;
        }
    }
}

extension CGPoint {
    mutating func translate(x: CGFloat, y: CGFloat) {
        self = self.applying(CGAffineTransform.identity.translatedBy(x: x, y: y))
    }
    
    mutating func translateBy(x: CGFloat) {
        self = self.applying(CGAffineTransform.identity.translatedBy(x: x, y: 0))
    }
    
    mutating func translateBy(y: CGFloat) {
        self = self.applying(CGAffineTransform.identity.translatedBy(x: 0, y: y))
    }
}
