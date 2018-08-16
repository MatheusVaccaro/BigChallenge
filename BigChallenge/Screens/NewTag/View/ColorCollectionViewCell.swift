//
//  ColorCollectionViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "colorCell"
    
    override var isSelected: Bool {
        didSet {
            isSelected ? select() : deselect()
        }
    }
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.frame = contentView.bounds
        layer.cornerRadius = layer.frame.height/2
        
        return layer
    }()
    
    
    func configure(with colorIndex: Int) {
        imageView.layer.zPosition = 1
        imageView.layer.cornerRadius = imageView.layer.frame.height / 2
        imageView.layer.masksToBounds = true
        let cgColors = TagModel.tagColors[ Int(colorIndex) ]
        gradientLayer.colors = cgColors
        contentView.layer.addSublayer(gradientLayer)
    }
    
    func select() {
        imageView.image = UIImage(named: "checkButton")
    }
    
    func deselect() {
        imageView.image = nil
    }
}
