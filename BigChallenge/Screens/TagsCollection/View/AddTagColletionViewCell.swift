//
//  AddTagColletionViewCell.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 23/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AddTagCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "addTagCollectionCell"
    
    private var gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var tagUILabel: UILabel!
    
    private lazy var maskLabel: UILabel = {
        let ans = UILabel()
        
        ans.textColor = UIColor.white
        ans.textAlignment = .center
        ans.font = UIFont.preferredFont(forTextStyle: .title3)
        
        return ans
    }()
    
    override var isSelected: Bool {
        didSet {
            contentView.mask = isSelected ? nil : maskLabel
            tagUILabel.isHidden = !isSelected
        }
    }
    
    private var viewModel: TagCollectionViewCellViewModel!
    
    override func awakeFromNib() {
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.clear.cgColor
        
        layer.cornerRadius = 6.3
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        layer.shadowRadius = 6.3
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
        
        createGradientLayer()
        
        tagUILabel.textColor = UIColor.white
        
        contentView.addSubview(maskLabel)
    }
    
    func configure(with viewModel: TagCollectionViewCellViewModel) {
        self.viewModel = viewModel
        
        tagUILabel.text = "+"
        maskLabel.text = "+"
        
        layer.shadowColor = viewModel.color.first!
        gradientLayer.colors = viewModel.color
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) ->
        UICollectionViewLayoutAttributes {
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
        gradientLayer.cornerRadius = 6.3
        gradientLayer.zPosition = -1
        
        contentView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        maskLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        tagUILabel.font = UIFont.preferredFont(forTextStyle: .title3)
        
        frame.size.width = tagUILabel.frame.size.width + 8*3
        gradientLayer.frame = bounds
        maskLabel.frame = bounds
    }
}
