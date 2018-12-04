//
//  ThemeTableViewCell.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

class ThemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var background: UIView!
    
    static let identifier: String = "ThemeCell"
    
    var viewModel: ThemeTableViewModel! {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        selectedImageView.contentMode = .center
        selectedImageView.isHidden = true
        backgroundColor = .clear
        
        topBackground.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        background.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner ]

        topBackground.layer.cornerRadius = 6.3
        background.layer.cornerRadius = 6.3
        
        layer.shadowRadius = 6.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.masksToBounds = false
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        
        layer.cornerRadius = 6.3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if viewModel.canSelect {
            super.touchesBegan(touches, with: event)
        } else {
            viewModel.buy()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedImageView.isHidden = !selected
        priceLabel.isHidden = selected
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        titleLabel.font = UIFont.font(sized: 18, weight: .medium, with: .title3)
        priceLabel.font = UIFont.font(sized: 13, weight: .regular, with: .body)
        selectedImageView.setNeedsLayout()
        selectedImageView.layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        layer.shadowColor = viewModel.theme.shadow
        super.layoutIfNeeded()
    }
    
    private func reloadData() {
        configureContent()
        configureColors()
        createTags()
    }
    
    private func configureContent() {
        titleLabel.text = viewModel.theme.name
        priceLabel.text = viewModel.priceText
        
        selectedImageView.image = UIImage(named: viewModel.selectedImageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    private func configureColors() {
        selectedImageView.tintColor = viewModel.theme.largeTitle
        titleLabel.textColor = viewModel.theme.largeTitle
        priceLabel.textColor = viewModel.theme.largeTitle
        topBackground.backgroundColor = viewModel.theme.tagsBackground
        background.backgroundColor = viewModel.theme.background
    }
    
    private func createTags() {
        let initialOriginX = 10
        
        for index in 0..<UIColor.tagColors.count+1 {
            let view = UIView()
            
            let width = 28
            let originX = initialOriginX + (index * (initialOriginX + width))
            
            view.frame = CGRect(x: originX, y: 10, width: width, height: width)
            
            view.layer.shadowRadius = 6.3
            view.layer.shadowOffset = CGSize(width: 0, height: 5)
            view.layer.masksToBounds = false
            view.layer.shadowColor = viewModel.theme.shadow
            view.layer.shadowOpacity = 1
            view.layer.shadowRadius = 5

            let gradientLayer = CAGradientLayer()
            gradientLayer.cornerRadius = 6.3
            gradientLayer.frame = view.bounds
            gradientLayer.masksToBounds = true
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.colors = index == 0
                ? viewModel.theme
                    .defaultGradient
                : UIColor.tagColors[index-1]
            
            view.layer.addSublayer(gradientLayer)
            
            if !view.isDescendant(of: background) {
                background.addSubview(view)
            }
        }
    }
}
