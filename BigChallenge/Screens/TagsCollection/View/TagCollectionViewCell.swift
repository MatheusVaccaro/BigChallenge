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
    
    enum Kind {
        case tag
        case add
    }
    var kind: Kind = .tag
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.cornerRadius = 6.3
        layer.zPosition = -1
        
        contentView.layer.addSublayer(layer)
        return layer
    }()
    
    @IBOutlet weak var tagUILabel: UILabel!
    
    lazy var maskLabel: UILabel = {
        let ans = UILabel()
        
        ans.textColor = UIColor.white
        ans.textAlignment = tagUILabel.textAlignment
        ans.font = tagUILabel.font
        
        return ans
    }()
    
    override var isSelected: Bool {
        didSet {
            switch kind {
            case .tag:
                contentView.mask = isSelected ? nil : maskLabel
                tagUILabel.isHidden = !isSelected
            case .add:
                break
                //code
            }
        }
    }
    
    private var viewModel: TagCollectionViewCellViewModel!
    
    override func awakeFromNib() {
        tagUILabel.font = UIFont.font(sized: 19, weight: .medium, with: .title3)
        
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.clear.cgColor
        
        layer.cornerRadius = 6.3
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        layer.shadowRadius = 6.3
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
        
        tagUILabel.textColor = UIColor.white
        
        contentView.addSubview(maskLabel)
    }
    
    func configure(with viewModel: TagCollectionViewCellViewModel? = nil) {
        
        guard let viewModel = viewModel else {
            configureDefault()
            
            return
        }
        
        self.viewModel = viewModel
        
        tagUILabel.text = viewModel.tagTitle
        maskLabel.text = viewModel.tagTitle
        
        layer.shadowColor = viewModel.color.first!
        gradientLayer.colors = viewModel.color
    }
    
    func configureDefault() {
        tagUILabel.text = "+"
        maskLabel.text = "+"
        gradientLayer.colors = UIColor.Tags.redGradient
        contentView.mask = maskLabel
        tagUILabel.isHidden = true
        kind = .add
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        maskLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        tagUILabel.font = UIFont.preferredFont(forTextStyle: .title3)
        
        frame.size.width = tagUILabel.frame.size.width + 8*3
        gradientLayer.frame = bounds
        maskLabel.frame = bounds
    }
}
