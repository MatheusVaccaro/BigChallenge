//
//  Colors.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

extension UIColor {
    static let largeTitleColor: UIColor =
        UIColor(red: 63/255.0, green: 69/255.0, blue: 79/255.0, alpha: 1)
    
    static let backgroundColor: UIColor =
        UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
    
    struct Cell {
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
    }
    
    struct DateInput {
        static let defaultColor: UIColor = UIColor.largeTitleColor
        
        static var shortcutButtonsColor: UIColor { return defaultColor }
        //swiftlint:disable nesting
        struct Calendar {
            static let weekday: UIColor = { return DateInput.defaultColor.adjusted(alpha: 0.5) }()
            static var month: UIColor { return DateInput.defaultColor }
            static let dateOffCurrentMonth: UIColor = { return DateInput.defaultColor.adjusted(alpha: 0.4) }()
            static let unselectableDate: UIColor = { return DateInput.defaultColor.adjusted(alpha: 0.2) }()
            static var deselectedDate: UIColor { return DateInput.defaultColor }
            static let deselectedDateBackground = UIColor.clear
            static let selectedDate = UIColor.white
            static var selectedDateBackground: UIColor { return DateInput.defaultColor }
        }
    }
    
    static var placeholder: UIColor {
        return UIColor(red: 63/255, green: 69/255, blue: 79/255, alpha: 0.3)
    }
}

extension UIColor {
    func adjusted(red: CGFloat? = nil, green: CGFloat? = nil, blue: CGFloat? = nil, alpha: CGFloat? = nil) -> UIColor {
        var oldRed: CGFloat = 0, oldGreen: CGFloat = 0, oldBlue: CGFloat = 0, oldAlpha: CGFloat = 0
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        
        return UIColor(red: red ?? oldRed, green: green ?? oldGreen, blue: blue ?? oldBlue, alpha: alpha ?? oldAlpha)
    }
}

extension CGColor {
    static let shadowColor: CGColor =
        UIColor(red: 116/255, green: 133/255, blue: 138/255, alpha: 0.3).cgColor
}
