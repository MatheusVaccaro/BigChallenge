//
//  TableViewCell.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String? = "OptionTableViewCell"

    @IBOutlet weak var optionIcon: UIImageView!
    @IBOutlet weak var optionTitle: UITextView!
    @IBOutlet weak var optionSubtitle: UILabel!
    
    var viewModel: OptionCellPresentable! {
        didSet {
            optionTitle.text = viewModel.title
            optionSubtitle.text = viewModel.subtitle
            optionIcon.image = UIImage(named: viewModel.imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        optionTitle.font = UIFont.font(sized: 25, weight: .medium, with: .title1)
        optionSubtitle.font = UIFont.font(sized: 14, weight: .regular, with: .title3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
