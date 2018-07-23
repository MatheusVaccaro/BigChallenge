//
//  TagCollectionViewCell.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TagCollectionViewCell: UICollectionViewCell {

    static let identifier = "tagCollectionCell"
    
    private var gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var tagUILabel: UILabel!
    
    private lazy var maskLabel: UILabel = {
        let ans = UILabel()
        
        ans.textAlignment = .center
        
        return ans
    }()
    
    override var isSelected: Bool {
        didSet {
            //TODO ask vini
//            self.contentView.backgroundColor = isSelected ? UIColor.black : UIColor.white
//            self.tagLabel.textColor = isSelected ? UIColor.white : UIColor.black
//            self.mask?.alpha = isSelected ? 0.75 : 1.0
        }
    }
    
    private var viewModel: TagCollectionViewCellViewModel!
    
    override func awakeFromNib() {
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.white.cgColor
        
        layer.cornerRadius = 6.3
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        layer.shadowRadius = 6.3
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
        
        createGradientLayer()
        
        contentView.addSubview(maskLabel)
        contentView.mask = maskLabel
        
        tagUILabel.isHidden = true
        maskLabel.font = tagUILabel.font
    }
    
    func configure(with viewModel: TagCollectionViewCellViewModel) {
        self.viewModel = viewModel
        
        tagUILabel.text = viewModel.tagTitle
        maskLabel.text = viewModel.tagTitle
        
        layer.shadowColor = viewModel.color.first!
        gradientLayer.colors = viewModel.color
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        var newFrame = layoutAttributes.frame
        newFrame.size.width = tagUILabel.frame.size.width + 8*3
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
    
    private func createGradientLayer() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        contentView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        maskLabel.frame = bounds
    }
}
