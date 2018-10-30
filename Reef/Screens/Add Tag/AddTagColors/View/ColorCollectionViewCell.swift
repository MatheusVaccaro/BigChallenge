//
//  ColorCollectionViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "colorCell"
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var gradientViewHeight: NSLayoutConstraint!
    
    override var isSelected: Bool {
        didSet {
            isSelected ? select() : deselect()
            CATransaction.disableAnimations {
            }
            
            UIView.animate(withDuration: 0, animations: {
                self.layoutIfNeeded()
                })
            self.gradientLayer.frame = self.gradientView.bounds
        }
    }
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.frame = gradientView.bounds
        layer.cornerRadius = layer.frame.height/3
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        layer.shadowRadius = layer.frame.height/3
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
        layer.shadowColor = ReefColors.shadow
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        
        return layer
    }()
    
    func configure(with colorIndex: Int) {
        gradientLayer.colors = UIColor.tagColors[colorIndex]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    func select() {
        gradientViewHeight.constant = 32
    }
    
    func deselect() {
        gradientViewHeight.constant = 28
    }
}
