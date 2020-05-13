//
//  SetCardView.swift
//  Set
//
//  Created by Вадим on 09.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

protocol SetCardViewProtocol {
    func drawFiguresInBounds(_ bounds: CGRect, with color: UIColor, with shading: SetCardFigureShading)
    func drawStrategyDependingOnCountOfFigures(number: SetCardCountOfFigures, color: UIColor, shading: SetCardFigureShading, bounds: CGRect)
    func drawStripedShadingForPath(_ pathOfSymbol: UIBezierPath)
    func drawShading(shading: SetCardFigureShading, with color: UIColor, in path: UIBezierPath)
}

extension SetCardViewProtocol {
    func drawFiguresInBounds(_ bounds: CGRect, with color: UIColor, with shading: SetCardFigureShading) { }
        
    func drawShading(shading: SetCardFigureShading, with color: UIColor, in path: UIBezierPath) {
          switch (shading) {
          case .solid:
              color.setFill()
              path.fill()
              break;
          case .striped:
              drawStripedShadingForPath(path)
              break;
          default:
              break;
          }
      }
    
    func drawStrategyDependingOnCountOfFigures(number: SetCardCountOfFigures, color: UIColor, shading: SetCardFigureShading, bounds: CGRect) {
        var bounds = bounds
        switch number {
        case .one:
            drawFiguresInBounds(bounds, with: color, with: .striped)
        case .two:
            // Variant 2:
            // fBounds = bounds.inset(by: .init(top: bounds.height*0.5, left: 0, bottom: 0, right: 0))
            // fBounds = bounds.inset(by: .init(top: 0, left: 0, bottom: bounds.height*0.5, right: 0))
            // Variant 1:
            bounds.makeYBoundSmaller(by: 2)
            bounds.origin.translateYBy(bounds.height*0.5)
            drawFiguresInBounds(bounds, with: color, with: .striped)
            bounds.origin.translateYBy(-bounds.height)
            drawFiguresInBounds(bounds, with: color, with: .striped)
        case .three:
            bounds.makeYBoundSmaller(by: 3)
            bounds.origin.translateYBy(bounds.height)
            drawFiguresInBounds(bounds, with: color, with: .striped)
            bounds.origin.translateYBy(-bounds.height)
            drawFiguresInBounds(bounds, with: color, with: .striped)
            bounds.origin.translateYBy(-bounds.height)
            drawFiguresInBounds(bounds, with: color, with: .striped)
        }
    }
    
    func drawStripedShadingForPath(_ pathOfSymbol: UIBezierPath) {
           let context = UIGraphicsGetCurrentContext()
           context?.saveGState()
           let bounds = pathOfSymbol.bounds
           let path = UIBezierPath()

           for i in stride(from: 0, through: bounds.size.width, by: 4) {
               path.move(to: CGPoint(x: bounds.origin.x + i, y: bounds.origin.y))
               path.addLine(to: CGPoint(x: bounds.origin.x + i, y: bounds.origin.y + bounds.size.height))
           }

           pathOfSymbol.addClip()
           path.stroke()
           context?.restoreGState()
       }
}

extension CGRect {
    mutating func makeYBoundSmaller(by multiplier: Int) {
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
    mutating func translateYBy(_ y: CGFloat) {
        self = self.applying(CGAffineTransform.identity.translatedBy(x: 0, y: y))
    }
}
