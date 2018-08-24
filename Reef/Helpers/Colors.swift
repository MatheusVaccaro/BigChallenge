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
        static let defaultColor: UIColor =
            UIColor(red: 80/255.0, green: 255/255.0, blue: 163/255.0, alpha: 1)
        
        static var shortcutButtonsColor: UIColor {
            return UIColor.DateInput.defaultColor
        }
        
        struct Calendar {
            static let dateOffCurrentMonth = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            static let deselectedDate = UIColor.black
            static let selectedDate = UIColor.DateInput.defaultColor
        }
    }
}

extension CGColor {
    static let shadowColor: CGColor =
        UIColor(red: 132/255, green: 153/255, blue: 159/255, alpha: 1).cgColor
}
