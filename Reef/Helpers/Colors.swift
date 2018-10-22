//
//  Colors.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol Theme {
    static var keyboardAppearance: UIKeyboardAppearance { get }
    
    static var largeTitle: UIColor { get }
    static var background: UIColor { get }
    static var placeholder: UIColor { get }
    static var shadow: CGColor { get }
    
    //MARK: - Cell
    static var darkGray: UIColor { get }
    static var lightGray: UIColor { get }
    static var deleteRed: UIColor { get }
    static var completeGreen: UIColor { get }
    static var uncompleteYellow: UIColor { get }
    
    //MARK: - Calendar
    static var deselectedDateBackground: UIColor { get }
    static var selectedDate: UIColor { get }
    
    static var weekday: UIColor { get }
    static var dateOffCurrentMonth: UIColor { get }
    static var unselectableDate: UIColor { get }
}

class Classic: Theme {
    static var keyboardAppearance: UIKeyboardAppearance = .light
    
    static var largeTitle: UIColor =
        UIColor(red: 63/255.0, green: 69/255.0, blue: 79/255.0, alpha: 1)
    
    static let background: UIColor =
        UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
    
    static let shadow: CGColor =
        UIColor(red: 116/255, green: 133/255, blue: 138/255, alpha: 0.3).cgColor
    
    static let placeholder: UIColor =
         UIColor(red: 63/255, green: 69/255, blue: 79/255, alpha: 0.3)
    
    //MARK: - Cell
    static let darkGray: UIColor =
        UIColor(red: 157/255.0, green: 168/255.0, blue: 169/255.0, alpha: 1)
    static let lightGray: UIColor =
        UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
    static let deleteRed: UIColor =
        UIColor(red: 255/255.0, green: 36/255.0, blue: 80/255.0, alpha: 1)
    static let completeGreen: UIColor =
        UIColor(red: 68/255.0, green: 252/255.0, blue: 202/255.0, alpha: 1)
    static let uncompleteYellow: UIColor =
        UIColor(red: 255/255.0, green: 200/255.0, blue: 50/255.0, alpha: 1)
    
    //MARK: - Calendar
    static let deselectedDateBackground = UIColor.clear
    static let selectedDate = UIColor.white
    
    static let weekday: UIColor = { return largeTitle.adjusted(alpha: 0.5) }()
    static let dateOffCurrentMonth: UIColor = { return largeTitle.adjusted(alpha: 0.4) }()
    static let unselectableDate: UIColor = { return largeTitle.adjusted(alpha: 0.2) }()
}

extension UIColor: Theme {
    
    static let theme: Theme.Type = Classic.self

    static let keyboardAppearance: UIKeyboardAppearance = theme.keyboardAppearance
    
    static let largeTitle: UIColor = theme.largeTitle
    static let background: UIColor = theme.background
    static let placeholder: UIColor = theme.placeholder
    static let shadow: CGColor = theme.shadow
    
    //MARK: - Cell
    static let darkGray: UIColor = theme.darkGray
    static let lightGray: UIColor = theme.lightGray
    static let deleteRed: UIColor = theme.deleteRed
    static let completeGreen: UIColor = theme.completeGreen
    static let uncompleteYellow: UIColor = theme.uncompleteYellow
    
    //MARK: - Calendar
    static let deselectedDateBackground: UIColor = theme.deselectedDateBackground
    static let selectedDate: UIColor = theme.selectedDate
    
    static let weekday: UIColor = theme.weekday
    static let dateOffCurrentMonth: UIColor = theme.dateOffCurrentMonth
    static let unselectableDate: UIColor = theme.unselectableDate
}

extension UIColor {
    func adjusted(red: CGFloat? = nil, green: CGFloat? = nil, blue: CGFloat? = nil, alpha: CGFloat? = nil) -> UIColor {
        var oldRed: CGFloat = 0, oldGreen: CGFloat = 0, oldBlue: CGFloat = 0, oldAlpha: CGFloat = 0
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        
        return UIColor(red: red ?? oldRed, green: green ?? oldGreen, blue: blue ?? oldBlue, alpha: alpha ?? oldAlpha)
    }
}
