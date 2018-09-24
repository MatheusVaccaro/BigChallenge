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
        
        static var shortcutButtonsColor: UIColor { return UIColor.black }
        //swiftlint:disable nesting
        struct Calendar {
            static let dateOffCurrentMonth: UIColor = {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                DateInput.defaultColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return UIColor(red: red, green: green, blue: blue, alpha: 0.3)
            }()
            static let unselectableDate: UIColor = {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                DateInput.defaultColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return UIColor(red: red, green: green, blue: blue, alpha: 0.1)
            }()
            static let deselectedDate = DateInput.defaultColor
            static let deselectedDateBackground = UIColor.clear
            static let selectedDate = UIColor.white
            static var selectedDateBackground: UIColor { return DateInput.defaultColor }
        }
    }
    
    static var placeholder: UIColor {
        return UIColor(red: 63/255, green: 69/255, blue: 79/255, alpha: 0.3)
    }
}

extension CGColor {
    static let shadowColor: CGColor =
        UIColor(red: 132/255, green: 153/255, blue: 159/255, alpha: 1).cgColor
}
