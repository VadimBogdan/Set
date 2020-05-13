//
//  SetCardView.swift
//  Set
//
//  Created by Вадим on 10.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class SetCardView: UIButton {
    private(set) var setCard: SetCard? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public func setNewSetCard(setCard: SetCard) {
        self.setCard = setCard
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
        UIColor.white.setFill()
        roundedRect.fill()
        chooseDrawStrategy()
    }
           
    func drawShading(shading: SetCardFigureShading, with color: UIColor, in path: UIBezierPath) {
        color.setFill()
        color.setStroke()
        switch (shading) {
        case .solid:
            path.fill()
            break;
        case .striped:
            drawStripedShadingForPath(path)
            break;
        default:
            break;
        }
     }
    
    func chooseDrawStrategy() {
        guard let setCard = setCard else { return }
        let twoOrOne: Bool = bounds.width/bounds.height <= 0.5 && (setCard.count == .one || setCard.count == .two)
        let three: Bool = bounds.width/bounds.height <= 0.333 && setCard.count == .three
        var strategy: DrawLayoutOfSetCardFigureStrategy
        if twoOrOne || three {
            strategy = DrawOnYAxis(bounds, setCard: setCard, shadingDrawer: drawShading(shading:with:in:))
        } else {
            strategy = DrawOnXAxis(bounds, setCard: setCard, shadingDrawer: drawShading(shading:with:in:))
        }
        strategy.draw()
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
    
    func select(with colour: UIColor) {
        layer.borderWidth = 5
        layer.borderColor = colour.cgColor
    }
    
    func deselect() {
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    
    init(frame: CGRect, setCard: SetCard) {
        super.init(frame: frame)
        self.setCard = setCard
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
