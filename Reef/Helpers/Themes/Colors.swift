//
//  Colors.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol Theme {
    
    static var identifier: String { get }
    static var name: String { get }
    
    static var statusBarStyle: UIStatusBarStyle { get }
    static var keyboardAppearance: UIKeyboardAppearance { get }
    static var blurStyle: UIBlurEffect.Style { get }
    static var iconName: String { get }
    
    static var defaultGradient: [CGColor] { get }
    static var largeTitle: UIColor { get }
    static var tagsBackground: UIColor { get }
    static var background: UIColor { get }
    static var placeholder: UIColor { get }
    static var shadow: CGColor { get }
    
    static var doneButtonBackground: UIColor { get }
    
    // MARK: - Cell
    static var sectionHeaderLabel: UIColor { get }
    static var sectionHeaderIcon: UIColor { get }
    static var iconCellIcon: UIColor { get }
    static var taskTitleLabel: UIColor { get }
    static var cellTagLabel: UIColor { get }
    static var cellIcons: UIColor { get }
    static var deleteRed: UIColor { get }
    static var completeGreen: UIColor { get }
    static var uncompleteYellow: UIColor { get }
    
    // MARK: - Calendar
    static var deselectedDateBackground: UIColor { get }
    static var selectedDateBackground: UIColor { get }
    static var selectedDate: UIColor { get }
    
    static var weekday: UIColor { get }
    static var dateOffCurrentMonth: UIColor { get }
    static var unselectableDate: UIColor { get }
    
    // MARK: - Empty State
    static var emptyStateOff: UIImage { get }
    static var emptyStateOn: UIImage { get }
}

extension Theme {
    static var deselectedDateBackground: UIColor { return UIColor.clear }
    
    static var selectedDate: UIColor { return UIColor.white }
    
    static var weekday: UIColor { return largeTitle.adjusted(alpha: 0.5) }
    static var dateOffCurrentMonth: UIColor { return largeTitle.adjusted(alpha: 0.4) }
    static var unselectableDate: UIColor { return largeTitle.adjusted(alpha: 0.2) }
}

class ReefColors: Theme {
    
    static var theme: Theme.Type = Dark.self
    
    static var identifier: String {
        return theme.identifier
    }
    
    static var name: String {
        return theme.name
    }
    
    // MARK: - Assets
    static var iconName: String {
        return theme.iconName
    }
    static var emptyStateOn: UIImage {
        return theme.emptyStateOn
    }
    static var emptyStateOff: UIImage {
        return theme.emptyStateOff
    }
    
    static var statusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    static var keyboardAppearance: UIKeyboardAppearance {
        return theme.keyboardAppearance
    }
    static var blurStyle: UIBlurEffect.Style {
        return theme.blurStyle
    }
    
    static var defaultGradient: [CGColor] {
        return theme.defaultGradient
    }
    static var largeTitle: UIColor {
        return theme.largeTitle
    }
    static var tagsBackground: UIColor {
        return theme.tagsBackground
    }
    static var background: UIColor {
        return theme.background
    }
    static var placeholder: UIColor {
        return theme.placeholder
    }
    static var shadow: CGColor {
        return theme.shadow
    }
    
    static var doneButtonBackground: UIColor {
        return theme.doneButtonBackground
    }
    
    // MARK: - Cell
    static var sectionHeaderLabel: UIColor {
        return theme.sectionHeaderLabel
    }
    static var sectionHeaderIcon: UIColor {
        return theme.sectionHeaderIcon
    }
    static var iconCellIcon: UIColor {
        return theme.iconCellIcon
    }
    static var taskTitleLabel: UIColor {
        return theme.taskTitleLabel
    }
    static var cellTagLabel: UIColor {
        return theme.cellTagLabel
    }
    static var cellIcons: UIColor {
        return theme.cellIcons
    }
    static var deleteRed: UIColor {
        return theme.deleteRed
    }
    static var completeGreen: UIColor {
        return theme.completeGreen
    }
    static var uncompleteYellow: UIColor {
        return theme.uncompleteYellow
    }
    
    // MARK: - Calendar
    static var deselectedDateBackground: UIColor {
        return theme.deselectedDateBackground
    }
    static var selectedDateBackground: UIColor {
        return theme.selectedDateBackground
    }
    static var selectedDate: UIColor {
        return theme.selectedDate
    }
    
    static var weekday: UIColor {
        return theme.weekday
    }
    static var dateOffCurrentMonth: UIColor {
        return theme.dateOffCurrentMonth
    }
    static var unselectableDate: UIColor {
        return theme.unselectableDate
    }
    
    private static var themeValueKey: String = "ThemeMultiValue"
    
    static var availableThemes: [Theme.Type] = [ Classic.self, Dark.self ]
    
    static func set(theme: Theme.Type) {
        let index = availableThemes.index { $0 == theme } ?? 0
        UserDefaults.standard.setValue(index, forKey: themeValueKey)
        loadTheme()
    }
    
    static func loadTheme() {
        let themeIndex = UserDefaults.standard.value(forKey: themeValueKey) as? Int ?? 0
        
        ReefColors.theme = availableThemes[themeIndex]
        
        UITextField.appearance().keyboardAppearance = ReefColors.theme.keyboardAppearance
        UIApplication.shared.setAlternateIconName(ReefColors.iconName) { (error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
}

extension UIColor {
    func adjusted(red: CGFloat? = nil, green: CGFloat? = nil, blue: CGFloat? = nil, alpha: CGFloat? = nil) -> UIColor {
        var oldRed: CGFloat = 0, oldGreen: CGFloat = 0, oldBlue: CGFloat = 0, oldAlpha: CGFloat = 0
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        
        return UIColor(red: red ?? oldRed, green: green ?? oldGreen, blue: blue ?? oldBlue, alpha: alpha ?? oldAlpha)
    }
}
