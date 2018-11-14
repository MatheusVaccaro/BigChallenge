//
//  SettingsCell.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    static var reuseIdentifier: String = "SettingsTableViewCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    
    private var viewModel: SettingsCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configWith(_ viewModel: SettingsCellViewModel) {
        
        self.viewModel = viewModel
        
        titleText.text = viewModel.title
        if viewModel.type == .selection {
            rightArrow.isHidden = false
        }
    }
}
