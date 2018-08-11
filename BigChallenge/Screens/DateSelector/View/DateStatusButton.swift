//
//  DateStatusButton.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class DateStatusButton: UILabel {
    
    var colorLayer: CAShapeLayer?
    var shadowLayer: CAShapeLayer?
    var isToggled: Bool = false {
        didSet { toggleBackground(to: isToggled) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.3
        self.font = UIFont.font(sized: 19.77, weight: .semibold, with: .body)
        self.textColor = UIColor.DateInput.defaultColor
        
//        configureColor()
//        configureShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        configureColor()
//        configureShadow()
    }

    private func configureColor() {
        let newColorLayer = CAShapeLayer()
        newColorLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4.3).cgPath
        newColorLayer.fillColor = isHighlighted ? UIColor.DateInput.defaultColor.cgColor : UIColor.clear.cgColor
        
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
        
        newShadowLayer.shadowColor = UIColor.darkGray.cgColor
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
    
    private func toggleBackground(to bool: Bool) {
        if bool {
            colorLayer?.fillColor = UIColor.DateInput.defaultColor.cgColor
            backgroundColor = UIColor.DateInput.defaultColor
            textColor = .white
            
        } else {
            colorLayer?.fillColor = UIColor.clear.cgColor
            backgroundColor = .clear
            textColor = UIColor.DateInput.defaultColor
        }
    }
}
