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
    
    @IBOutlet weak var tagUILabel: UILabel!
    
    var touchedTagEvent: PublishSubject<UITouch>?
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.black : UIColor.white
            self.tagUILabel.textColor = isSelected ? UIColor.white : UIColor.black
            self.mask?.alpha = isSelected ? 0.75 : 1.0
        }
    }
    
    private var viewModel: TagCollectionViewCellViewModel!
    private var isWidthCalculated = false
    
    func configure(with viewModel: TagCollectionViewCellViewModel) {
        touchedTagEvent = PublishSubject()
        
        self.viewModel = viewModel
        
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.borderColor = UIColor.clear.cgColor

        contentView.layer.cornerRadius = 2.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
        tagUILabel.text = viewModel.tagTitle
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !isWidthCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            var newFrame = layoutAttributes.frame
            newFrame.size.width =  tagUILabel.frame.size.width + 10
            layoutAttributes.frame = newFrame
            isWidthCalculated = true
        }
        return layoutAttributes
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchedTagEvent?.onNext(touch)
    }
}
