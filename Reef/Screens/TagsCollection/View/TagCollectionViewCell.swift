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
            contentView.mask = isSelected ? nil : maskLabel
            tagUILabel.isHidden = !isSelected
            
            if kind == .add, isSelected { // add tag is never selected
                isSelected = false
            }
        }
    }
    
    private(set) var viewModel: TagCollectionViewCellViewModel?
    
    private var longPressRecognizer: UILongPressGestureRecognizer!
    
    override func awakeFromNib() {
        tagUILabel.font = UIFont.font(sized: 19, weight: .medium, with: .title3)
        
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.clear.cgColor
        
        layer.cornerRadius = 6.3
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        layer.shadowRadius = 6.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.masksToBounds = false
        layer.shadowColor = CGColor.shadowColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        
        tagUILabel.textColor = UIColor.white
        
        accessibilityIgnoresInvertColors = true
        tagUILabel.accessibilityIgnoresInvertColors = true
        
        contentView.addSubview(maskLabel)
        kind = .tag
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    }
    
    deinit {
        removeGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func handleLongPress() {
        guard let viewModel = viewModel else { return }
        viewModel.longPressedTag.onNext(viewModel.tag)
    }
    
    func configure(with viewModel: TagCollectionViewCellViewModel? = nil) {
        self.viewModel = viewModel
        configureAccessibility()
        
        guard let viewModel = viewModel else {
            configureDefault()
            return
        }
        
        addGestureRecognizer(longPressRecognizer)
        tagUILabel.text = viewModel.tagTitle
        maskLabel.text = viewModel.tagTitle
        gradientLayer.colors = viewModel.colors
        kind = .tag
    }
    
    func configureDefault() {
        removeGestureRecognizer(longPressRecognizer)
        tagUILabel.text = "+"
        maskLabel.text = "+"
        
        gradientLayer.colors = [UIColor.largeTitleColor.cgColor, UIColor.largeTitleColor.cgColor]
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
        CATransaction.disableAnimations {
            super.layoutSubviews()
            
            maskLabel.font = UIFont.preferredFont(forTextStyle: .title3)
            tagUILabel.font = UIFont.preferredFont(forTextStyle: .title3)
            
            frame.size.width = tagUILabel.frame.size.width + 8*3
            gradientLayer.frame = bounds
            maskLabel.frame = bounds
            contentView.frame = bounds
        }
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = viewModel?.tagTitle ?? Strings.Tag.CollectionScreen.VoiceOver.AddTag.label
        
        accessibilityHint = kind == .tag
            ? Strings.Tag.CollectionScreen.VoiceOver.Tag.hint
            : Strings.Tag.CollectionScreen.VoiceOver.AddTag.hint
        
        accessibilityValue = isSelected
            ? Strings.Tag.CollectionScreen.VoiceOver.Tag.valueSelected
            : Strings.Tag.CollectionScreen.VoiceOver.Tag.valueDeselected
        
        accessibilityTraits = UIAccessibilityTraits.button
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSelected, let viewModel = viewModel, viewModel.tag.requiresAuthentication {
            Authentication.authenticate { sucess in
                if sucess {
                    DispatchQueue.main.sync {
                        super.touchesEnded(touches, with: event)
                    }
                }
            }
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
}
