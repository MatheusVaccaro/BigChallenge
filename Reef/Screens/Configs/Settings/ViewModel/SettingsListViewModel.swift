//
//  SettingsListViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

enum SettingsCellType {
    case singleAction, selection, toggleable
}

class SettingsListViewModel {
    
    func viewModelForCellIn(_ indexPath: IndexPath) -> SettingsCellViewModel? {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return SettingsCellViewModel(type: .selection, title: Strings.Settings.Theme.chooseTheme)
            case 1:
                return SettingsCellViewModel(type: .singleAction, title: Strings.Settings.Theme.restorePurchases)
            default:
                return nil
            }
        case 1:
            switch indexPath.row {
            case 0:
                return SettingsCellViewModel(type: .singleAction, title: Strings.Settings.Social.rateReef)
            case 1:
                return SettingsCellViewModel(type: .singleAction, title: Strings.Settings.Social.reefSubreddit)
            case 2:
                return SettingsCellViewModel(type: .selection, title: Strings.Settings.Social.shareReef)
            default:
                return nil
            }
        case 2:
            switch indexPath.row {
            case 0:
                return SettingsCellViewModel(type: .toggleable, title: Strings.Settings.System.remindersSync)
            case 1:
                return SettingsCellViewModel(type: .selection, title: Strings.Settings.System.language)
            case 2:
                return SettingsCellViewModel(type: .selection, title: Strings.Settings.System.termsOfService)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func numberOfRowsIn(_ section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func numberOfSections() -> Int {
        return 3
    }
    
    func nameFor(_ section: Int) -> String {
        switch section {
        case 0:
            return Strings.Settings.Theme.sectionTitle
        case 1:
            return Strings.Settings.Social.sectionTitle
        case 2:
            return Strings.Settings.System.sectionTitle
        default:
            return Strings.Settings.System.sectionTitle
        }
    }
    
    func sectionImageNameFor(_ section: Int) -> String {
        switch section {
        case 0:
            return Strings.Settings.Theme.sectionImage
        case 1:
            return Strings.Settings.Social.sectionImage
        case 2:
            return Strings.Settings.System.sectionImage
        default:
            return Strings.Settings.System.sectionImage
        }
    }
}
