//
//  ThemeTableViewCell.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
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
        
        selectedView.isHidden = true
        backgroundColor = .clear
        
        topBackground.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        background.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner ]

        topBackground.layer.cornerRadius = 6.3
        background.layer.cornerRadius = 6.3
        
        layer.shadowRadius = 6.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.masksToBounds = false
        layer.shadowColor = ReefColors.shadow
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        
        layer.cornerRadius = 6.3
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //set fonts
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedView.isHidden = false
        
        // buy
    }
    
    private func reloadData() {
        titleLabel.text = "titlePlaceholder"
        priceLabel.text = "price"
        
        configureTexts()
        configureColors()
        createTags()
    }
    
    private func configureTexts() {
        titleLabel.text = viewModel.theme.name
    }
    
    private func configureColors() {
        titleLabel.textColor = viewModel.theme.largeTitle
        priceLabel.textColor = viewModel.theme.largeTitle
        topBackground.backgroundColor = viewModel.theme.tagsBackground
        background.backgroundColor = viewModel.theme.background
    }
    
    private func createTags() {
        
    }
}
