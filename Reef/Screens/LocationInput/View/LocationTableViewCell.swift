//
//  LocationTableViewCell.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 06/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font =
            UIFont.font(sized: 17, weight: .regular, with: .body)
        subtitleLabel.font =
            UIFont.font(sized: 12, weight: .regular, with: .footnote)
    }
}
