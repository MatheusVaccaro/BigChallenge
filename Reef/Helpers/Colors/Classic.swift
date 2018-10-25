//
//  Classic.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class Classic: Theme {
    
    static let statusBarStyle: UIStatusBarStyle = .default
    static let keyboardAppearance: UIKeyboardAppearance = .light
    static let blurStyle: UIBlurEffect.Style = .light
    
    static let largeTitle: UIColor =
        UIColor(red: 63/255.0, green: 69/255.0, blue: 79/255.0, alpha: 1)
    
    static let tagsBackground: UIColor = .white
    
    static let background: UIColor =
        UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
    
    static let shadow: CGColor =
        UIColor(red: 116/255, green: 133/255, blue: 138/255, alpha: 0.3).cgColor
    
    static let placeholder: UIColor =
        UIColor(red: 63/255, green: 69/255, blue: 79/255, alpha: 0.3)
    
    static let doneButtonBackground: UIColor = .largeTitle
    
    static let defaultGradient: [CGColor] =
        [UIColor.black.cgColor, UIColor.black.cgColor]
    
    // MARK: - Cell
    static let iconCellIcon: UIColor = .black
    static let taskTitleLabel: UIColor = .black
    
    static let cellTagLabel: UIColor =
        UIColor(red: 157/255.0, green: 168/255.0, blue: 169/255.0, alpha: 1)
    static let cellIcons: UIColor =
        UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
    static let deleteRed: UIColor =
        UIColor(red: 255/255.0, green: 36/255.0, blue: 80/255.0, alpha: 1)
    static let completeGreen: UIColor =
        UIColor(red: 68/255.0, green: 252/255.0, blue: 202/255.0, alpha: 1)
    static let uncompleteYellow: UIColor =
        UIColor(red: 255/255.0, green: 200/255.0, blue: 50/255.0, alpha: 1)
    
    static let selectedDateBackground: UIColor = .largeTitle
}
