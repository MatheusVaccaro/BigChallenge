//
//  SettingsCoordinator.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class SettingsCoordinator: Coordinator {
    
    var childrenCoordinators: [Coordinator]
    var presenter: UINavigationController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.childrenCoordinators = []
    }
    
    func start() {
        showThemeSelection()
    }
    
    private func showThemeSelection() {
        let settingsViewController = ThemeSelectViewController.instantiate()
        settingsViewController.title = Strings.Settings.Theme.title
        
        presenter.pushViewController(settingsViewController, animated: true)
    }
}
