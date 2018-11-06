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
                     with style: UIFont.TextStyle,
                     fontName: FontName = .system) -> UIFont {
        let font = fontNamed(name: fontName, weight: weight, size: size)
        
        let fontMetrics = UIFontMetrics(forTextStyle: style)
        let finalFont = fontMetrics.scaledFont(for: font)
        return finalFont
    }
    
    public static func font(sized size: CGFloat,
                            weight: String,
                            with style: UIFont.TextStyle,
                            fontName: FontName = .system) -> UIFont {
        let font = UIFont(name: fontName.rawValue + weight, size: size)!
        
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
        case .thin:
            return FontWeight.thin
        case .semibold:
            return FontWeight.semiBold
        default:
            return FontWeight.regular
        }
    }
    
    public func monospaced() -> UIFont {
        let fontDescriptorFeatureSettings = [UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                                             UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: [fontDescriptorFeatureSettings]]
        let monospacedFontDescriptor = fontDescriptor.addingAttributes(fontDescriptorAttributes)
        
        return UIFont.init(descriptor: monospacedFontDescriptor, size: 0)
    }
    
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
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
    public static let thin = "-Thin"
    public static let extraLight = "-ExtraLight"
    public static let light = "-Light"
    public static let regular = "-Regular"
    public static let medium = "-Medium"
    public static let semiBold = "-SemiBold"
    public static let bold = "-Bold"
    public static let extraBold = "-ExtraBold"
    public static let black = "-Black"
    public static let thinItalic = "-ThinItalic"
    public static let extraLightItalic = "-ExtraLightItalic"
    public static let lightItalic = "-LightItalic"
    public static let italic = "-Italic"
    public static let mediumItalic = "-MediumItalic"
    public static let semiBoldItalic = "-SemiBoldItalic"
    public static let boldItalic = "-BoldItalic"
    public static let extraBoldItalic = "-ExtraBoldItalic"
    public static let blackItalic = "-BlackItalic"}
