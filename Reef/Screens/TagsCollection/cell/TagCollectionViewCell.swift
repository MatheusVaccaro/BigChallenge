//
//  TagCollectionViewCell.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

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
        
        layer.borderColor = UIColor.clear.cgColor
        
        layer.cornerRadius = 6.3
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        layer.shadowRadius = 6.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.masksToBounds = false
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        
        tagUILabel.textColor = UIColor.white
        
        accessibilityIgnoresInvertColors = true
        tagUILabel.accessibilityIgnoresInvertColors = true
        
        contentView.addSubview(maskLabel)
        kind = .tag
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        configureColors()
        configureLocked()
    }
    
    deinit {
        removeGestureRecognizer(longPressRecognizer)
    }
    
    func configureColors() {
        layer.backgroundColor = ReefColors.tagsBackground.cgColor
        layer.shadowColor = ReefColors.shadow
    }
    
    @objc private func handleLongPress() {
        guard let viewModel = viewModel else { return }
        viewModel.performLongPress()
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
        lockerGradientLayer.colors = viewModel.colors
        lockerGradientLayer.isHidden = !viewModel.tag.requiresAuthentication
        kind = .tag
    }
    
    func configureDefault() {
        removeGestureRecognizer(longPressRecognizer)
        tagUILabel.text = "+"
        maskLabel.text = "+"
        
        gradientLayer.colors = ReefColors.defaultGradient
        contentView.mask = maskLabel
        tagUILabel.isHidden = true
        kind = .add
    }
    
    private var lockerGradientLayer: CAGradientLayer = CAGradientLayer()
    private var lockerView: UIView = UIView()
    
    private func configureLocked() {
        guard !lockerView.isDescendant(of: self) else {
            return
        }
        
        let maskView = UIImageView(image: UIImage(named: "lockIcon"))
        
        lockerView.frame = CGRect(x: frame.width-7, y: -6, width: 10, height: 14)
        lockerGradientLayer.frame = lockerView.bounds
        maskView.frame = lockerView.bounds
        maskView.contentMode = .scaleAspectFit
        
        lockerView.layer.addSublayer(lockerGradientLayer)
        lockerView.mask = maskView
        
        clipsToBounds = false
        addSubview(lockerView)
        lockerGradientLayer.isHidden = true
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) ->
        UICollectionViewLayoutAttributes {
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
            
            gradientLayer.frame = bounds
            maskLabel.frame = bounds
            contentView.frame = bounds
            lockerView.frame = CGRect(x: frame.width-7, y: -6, width: 10, height: 14)
            lockerGradientLayer.frame = lockerView.bounds
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
