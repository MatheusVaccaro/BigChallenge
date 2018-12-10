//
//  SettingsCell.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class SettingsToggleableCell: SettingsCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    private var viewModel: SettingsCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellSwitch.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
        cellSwitch.thumbTintColor = ReefColors.theme.cellTagLabel
        cellSwitch.onTintColor = ReefColors.theme.largeTitle
        
        cellSwitch.isOn = RemindersImporter.shared().isSyncingEnabled
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if touches.count < 2 {
            RemindersImporter.shared().isSyncingEnabled.toggle()
            cellSwitch.setOn(RemindersImporter.shared().isSyncingEnabled, animated: true)
        }
    }
    
    
    override func configWith(_ viewModel: SettingsCellViewModel) {
        super.configWith(viewModel)
        
    }
}
