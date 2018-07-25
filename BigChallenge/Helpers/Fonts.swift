//
//  Fonts.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 25/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    static func font(sized size: CGFloat, weight: UIFont.Weight, with style: UIFontTextStyle) -> UIFont {
        
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        let fontMetrics = UIFontMetrics(forTextStyle: style)
        let finalFont = fontMetrics.scaledFont(for: font)
        
        return finalFont
    }
}
