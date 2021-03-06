//
//  DateStatusButton.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class ToggleableLabel: UILabel {
    
    var colorLayer: CAShapeLayer?
    var shadowLayer: CAShapeLayer?
    var isToggled: Bool = false {
        didSet { toggleBackground(on: isToggled) }
    }
    
    private static let toggledOnFont = UIFont.font(sized: 19.77, weight: .regular, with: .body)
    private static let toggledOffFont = UIFont.font(sized: 19.77, weight: .semibold, with: .body)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.3
        self.font = ToggleableLabel.toggledOffFont
        self.textColor = ReefColors.largeTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func toggleBackground(on bool: Bool) {
        if bool {
            colorLayer?.fillColor = ReefColors.largeTitle.cgColor
            backgroundColor = ReefColors.largeTitle
            textColor = .white
            font = ToggleableLabel.toggledOnFont
            
        } else {
            colorLayer?.fillColor = UIColor.clear.cgColor
            backgroundColor = .clear
            textColor = ReefColors.largeTitle
            font = ToggleableLabel.toggledOffFont
        }
    }
    
    // Unused methods. Use these when implementing the dropshadow this component currently lacks.
    private func configureColor() {
        let newColorLayer = CAShapeLayer()
        newColorLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4.3).cgPath
        newColorLayer.fillColor = isHighlighted ? ReefColors.largeTitle.cgColor : UIColor.clear.cgColor
        
        if let colorLayer = colorLayer {
            layer.replaceSublayer(colorLayer, with: newColorLayer)
        } else {
            layer.insertSublayer(newColorLayer, at: 0)
        }
        colorLayer = newColorLayer
    }
    
    private func configureShadow() {
        let newShadowLayer = CAShapeLayer()
        newShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4.3).cgPath
        newShadowLayer.fillColor = UIColor.white.cgColor
        
        newShadowLayer.shadowColor = ReefColors.cellTagLabel.cgColor
        newShadowLayer.shadowPath = newShadowLayer.path
        newShadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        newShadowLayer.shadowOpacity = 0.8
        newShadowLayer.shadowRadius = 2
        
        if let shadowLayer = shadowLayer {
            layer.replaceSublayer(shadowLayer, with: newShadowLayer)
        } else {
            layer.insertSublayer(newShadowLayer, at: 0)
        }
        shadowLayer = newShadowLayer
    }
    
}
