//
//  TableViewCell.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String? = "IconTableViewCell"

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var titleFontSize: CGFloat = 25 {
        didSet {
            titleLabel.font = UIFont.font(sized: titleFontSize, weight: .medium, with: .title1)
        }
    }
    var subtitleFontSize: CGFloat = 14 {
        didSet {
            subtitleLabel.font = UIFont.font(sized: subtitleFontSize, weight: .regular, with: .title3)
        }
    }
    
    var iconSize: CGFloat = 66.5 {
        didSet {
            imageHeight.constant = iconSize
        }
    }
    
    var viewModel: IconCellPresentable! {
        didSet {
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.subtitle
            icon.image = UIImage(named: viewModel.imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        titleLabel.font = UIFont.font(sized: titleFontSize, weight: .medium, with: .title1)
        subtitleLabel.font = UIFont.font(sized: subtitleFontSize, weight: .regular, with: .title3)
        
        titleLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel.textContainer.lineFragmentPadding = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        titleLabel.font = UIFont.font(sized: titleFontSize, weight: .medium, with: .title1)
        subtitleLabel.font = UIFont.font(sized: subtitleFontSize, weight: .regular, with: .title3)
    }
}