//
//  FigureDrawer.swift
//  Set
//
//  Created by Вадим on 13.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation
import UIKit

struct FigureDrawer {
    private var affineTransformations: ((CGRect, UIBezierPath)->Void)?
    private var shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?
    private var bounds: CGRect = .zero
    private var shading: SetCardFigureShading = .open
    private var figure: SetCardFigure = .oval
    private var color: UIColor = .clear
    
    init(setCard: SetCard) {
        figure = setCard.figure
        shading = setCard.shading
        color = UIColor.setCardColor(setCard.color)
    }
    
    mutating func draw(in bounds: CGRect, affineTransformations: ((CGRect, UIBezierPath)->Void)?, shadingDrawer: ((SetCardFigureShading, UIColor, UIBezierPath)->Void)?) {
        self.bounds = bounds
        self.affineTransformations = affineTransformations
        self.shadingDrawer = shadingDrawer
        switch figure {
        case .diamond:
            drawDiamond()
        case .oval:
            drawOval()
        case .squiggle:
            drawSquiggle()
        }
    }
    
    fileprivate func drawDiamond()  {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.1, y: bounds.origin.y + bounds.size.height*0.5))
        path.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.5, y: bounds.origin.y + bounds.size.height*0.2))
        path.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.9, y: bounds.origin.y + bounds.size.height*0.5))
        path.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.5, y: bounds.origin.y + bounds.size.height*0.8))
        path.close()
        affineTransformations?(bounds, path)
        shadingDrawer?(shading, color, path)
        path.stroke();
    }
    
    fileprivate func drawOval()  {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.25, y: bounds.origin.y + bounds.size.height*0.2))
        path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.25, y: bounds.origin.y + bounds.size.height*0.8),
                      controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.0, y: bounds.origin.y + bounds.size.height*0.2),
                      controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.0, y: bounds.origin.y + bounds.size.height*0.8))
        path.addLine(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.75, y: bounds.origin.y + bounds.size.height*0.8))
        
        path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.75, y: bounds.origin.y + bounds.size.height*0.2),
                                 controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*1, y: bounds.origin.y + bounds.size.height*0.80),
                                 controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*1, y: bounds.origin.y + bounds.size.height*0.20))

        path.close()
        affineTransformations?(bounds, path)
        shadingDrawer?(shading, color, path)
        path.stroke();
    }

    fileprivate func drawSquiggle()  {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.05, y: bounds.origin.y + bounds.size.height*0.40))
        path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.35, y: bounds.origin.y + bounds.size.height*0.25),
                            controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.09, y: bounds.origin.y + bounds.size.height*0.15),
                            controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.18, y: bounds.origin.y + bounds.size.height*0.10))
              
              path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.75, y: bounds.origin.y + bounds.size.height*0.30),
                                   controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.40, y: bounds.origin.y + bounds.size.height*0.30),
                                   controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.60, y: bounds.origin.y + bounds.size.height*0.45))

              path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.97, y: bounds.origin.y + bounds.size.height*0.35),
                          controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.87, y: bounds.origin.y + bounds.size.height*0.15),
                          controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.98, y: bounds.origin.y + bounds.size.height*0.00))
              
              path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.45, y: bounds.origin.y + bounds.size.height*0.85),
                                 controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.95, y: bounds.origin.y + bounds.size.height*1.10),
                                 controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.50, y: bounds.origin.y + bounds.size.height*0.95))
              
              path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.25, y: bounds.origin.y + bounds.size.height*0.85),
                                 controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.40, y: bounds.origin.y + bounds.size.height*0.80),
                                 controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.35, y: bounds.origin.y + bounds.size.height*0.75))
              
              path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.05, y: bounds.origin.y + bounds.size.height*0.40),
                                 controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.00, y:bounds.origin.y + bounds.size.height*1.10),
                                 controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.005, y: bounds.origin.y + bounds.size.height*0.60))
        path.close()
        affineTransformations?(bounds, path)
        shadingDrawer?(shading, color, path)
        path.stroke();
    }

}
