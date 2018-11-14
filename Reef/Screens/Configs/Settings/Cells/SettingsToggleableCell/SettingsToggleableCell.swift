//
//  SettingsCell.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class SettingsToggleableCell: UITableViewCell {

    static var reuseIdentifier: String = "SettingsToggleableTableViewCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleText: UILabel!
    
    private var viewModel: SettingsCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configWith(_ viewModel: SettingsCellViewModel) {
        
        self.viewModel = viewModel
        
        titleText.text = viewModel.title
    }
}
