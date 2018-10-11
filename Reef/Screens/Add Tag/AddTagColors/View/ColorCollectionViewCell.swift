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
                self.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.gradientLayer.frame = self.gradientView.bounds
                })
        }
    }
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.frame = contentView.bounds
        layer.cornerRadius = layer.frame.height/3.5
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor
        // TODO: Should increase cell size so that the shadow have space in the view
//        layer.shadowRadius = layer.frame.height/3.5
//        layer.shadowOffset = CGSize(width: 0, height: 3)
//        layer.masksToBounds = false
//        layer.shadowColor = CGColor.shadowColor
//        layer.shadowOpacity = 1
//        layer.shadowRadius = 4
        
        return layer
    }()
    
    func configure(with colorIndex: Int) {
        imageView.layer.zPosition = 1
        imageView.layer.cornerRadius = imageView.layer.frame.height / 3.5
        imageView.layer.masksToBounds = true
        gradientLayer.colors = UIColor.tagColors[colorIndex]
        contentView.layer.addSublayer(gradientLayer)
    }
    
    func select() {
//        imageView.image = UIImage(named: "option")
        gradientLayer.borderColor = UIColor.black.cgColor
    }
    
    func deselect() {
//        imageView.image = nil
        gradientLayer.borderColor = UIColor.white.cgColor
    }
}
