//
//  Colors.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

extension UIColor {
    static let backGroundGradient: [CGColor] = [
        UIColor(red: 247/255, green: 247/255, blue: 250/255, alpha: 1).cgColor,
        UIColor(red: 235/255, green: 239/255, blue: 250/255, alpha: 1).cgColor
    ]
    
    struct DateInput {
        static let defaultColor: UIColor = UIColor(red: 63/255.0, green: 69/255.0, blue: 79/255.0, alpha: 1)
        
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
        UIColor(red: 132/255, green: 153/255, blue: 159/255, alpha: 1).cgColor
}
