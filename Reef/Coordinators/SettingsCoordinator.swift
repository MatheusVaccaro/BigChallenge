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
        showSettings()
    }
    
    private func showThemeSelection() {
        let settingsViewController = ThemeSelectViewController.instantiate()
        settingsViewController.title = Strings.Settings.Theme.title
        
        presenter.pushViewController(settingsViewController, animated: true)
    }
    
    private func showSettings() {
        let settingsViewController = SettingsListViewController.instantiate()
        let settingsViewModel = SettingsListViewModel()
        
        settingsViewController.viewModel = settingsViewModel
        settingsViewController.delegate = self
        
        settingsViewController.title = Strings.Settings.title
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        presenter.view.layer.add(transition, forKey: nil)
        
        presenter.pushViewController(settingsViewController, animated: false)
    }
}

extension SettingsCoordinator: SettingsListViewControllerDelegate {
    func didPressThemeCell() {
        showThemeSelection()
    }
}
