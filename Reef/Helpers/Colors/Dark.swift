//
//  Dark.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class Dark: Theme {
    static let statusBarStyle: UIStatusBarStyle = .lightContent
    static let keyboardAppearance: UIKeyboardAppearance = .dark
    static let blurStyle: UIBlurEffect.Style = .dark
    
    static let largeTitle: UIColor = .white
    
    static let tagsBackground: UIColor =
        UIColor(red: 50.0/255.0, green: 51.0/255.0, blue: 52.0/255.0, alpha: 1)
    
    static let background: UIColor =
        UIColor(red: 29.0/255.0, green: 30.0/255.0, blue: 31.0/255.0, alpha: 1)
    
    static let shadow: CGColor =
        UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5).cgColor
    
    static let placeholder: UIColor =
        UIColor(red: 132.0/255, green: 132.0/255, blue: 133.0/255, alpha: 0.3)
    
    static let doneButtonBackground: UIColor = .background
    
    static let defaultGradient: [CGColor] =
        [UIColor.placeholder.cgColor, UIColor.placeholder.cgColor]
    
    // MARK: - Cell
    static let iconCellIcon: UIColor = .placeholder
    static let taskTitleLabel: UIColor = .white
    
    static let cellTagLabel: UIColor =
        UIColor(red: 157/255.0, green: 168/255.0, blue: 169/255.0, alpha: 1)
    
    static let cellIcons: UIColor =
        UIColor(red: 119/255.0, green: 120/255.0, blue: 121/255.0, alpha: 1)
    
    static let deleteRed: UIColor =
        UIColor(red: 255/255.0, green: 36/255.0, blue: 80/255.0, alpha: 1)
    
    static let completeGreen: UIColor =
        UIColor(red: 68/255.0, green: 252/255.0, blue: 202/255.0, alpha: 1)
    
    static let uncompleteYellow: UIColor =
        UIColor(red: 255/255.0, green: 200/255.0, blue: 50/255.0, alpha: 1)
    
    static let selectedDateBackground: UIColor = .tagsBackground
}
