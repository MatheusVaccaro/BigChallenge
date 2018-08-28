//
//  Fonts.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 25/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

public extension UIFont {
    public static func font(sized size: CGFloat,
                     weight: UIFont.Weight,
                     with style: UIFontTextStyle,
                     fontName: FontName = .system) -> UIFont {
        let font = fontNamed(name: fontName, weight: weight, size: size)
        
        let fontMetrics = UIFontMetrics(forTextStyle: style)
        let finalFont = fontMetrics.scaledFont(for: font)
        return finalFont
    }
    
    public static func fontNamed(name: FontName, weight: UIFont.Weight, size: CGFloat) -> UIFont {
        guard name != FontName.system else { return UIFont.systemFont(ofSize: size, weight: weight)}
        let weightName = fontWeight(for: weight)
        return UIFont(name: name.rawValue + weightName, size: size)!
    }
    
    public static func fontWeight(for weight: UIFont.Weight) -> String {
        switch weight {
        case .thin:
            return FontWeight.thin
        case .light:
            return FontWeight.light
        case .regular:
            return FontWeight.regular
        case .medium:
            return FontWeight.medium
        case .bold:
            return FontWeight.bold
        case .black:
            return FontWeight.black
        default:
            return FontWeight.regular
        }
    }
    
    private func withTraits(traits: UIFontDescriptorSymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
}

public enum FontName: String {
    public typealias RawValue = String
    case system
    case barlow = "Barlow"
}

public struct FontWeight {
    static let thin = "-Thin"
    static let extraLight = "-ExtraLight"
    static let light = "-Light"
    static let regular = "-Regular"
    static let medium = "-Medium"
    static let semiBold = "-SemiBold"
    static let bold = "-Bold"
    static let extraBold = "-ExtraBold"
    static let black = "-Black"
    static let thinItalic = "-ThinItalic"
    static let extraLightItalic = "-ExtraLightItalic"
    static let lightItalic = "-LightItalic"
    static let italic = "-Italic"
    static let mediumItalic = "-MediumItalic"
    static let semiBoldItalic = "-SemiBoldItalic"
    static let boldItalic = "-BoldItalic"
    static let extraBoldItalic = "-ExtraBoldItalic"
    static let blackItalic = "-BlackItalic"}
