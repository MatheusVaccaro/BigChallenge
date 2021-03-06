//
//  SettingsCell.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    
    private var viewModel: SettingsCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        titleText.font = UIFont.font(sized: 15, weight: .regular, with: .body)
        titleText.textColor = ReefColors.theme.cellTagLabel
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func configWith(_ viewModel: SettingsCellViewModel) {
        
        self.viewModel = viewModel
        
        titleText.text = viewModel.title
        
        if viewModel.type == .selection {
            rightArrow.isHidden = false
            NSLayoutConstraint.activate([
                rightArrow.leftAnchor.constraint(equalTo: titleText.rightAnchor, constant: 8)
                ])
//            if let image = UIImage(named: viewModel.rightArrowImageName) {
//                rightArrow.image = image.withRenderingMode(.alwaysTemplate)
//                imageView?.tintColor = ReefColors.theme.cellTagLabel
//            }
        }
    }
}
