//
//  Colors.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol Theme {
    static var statusBarStyle: UIStatusBarStyle { get }
    static var keyboardAppearance: UIKeyboardAppearance { get }
    static var blurStyle: UIBlurEffect.Style { get }
    
    static var defaultGradient: [CGColor] { get }
    static var largeTitle: UIColor { get }
    static var tagsBackground: UIColor { get }
    static var background: UIColor { get }
    static var placeholder: UIColor { get }
    static var shadow: CGColor { get }
    
    static var doneButtonBackground: UIColor { get }
    
    // MARK: - Cell
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
}

extension Theme {
    static var deselectedDateBackground: UIColor { return UIColor.clear }
    
    static var selectedDate: UIColor { return UIColor.white }
    
    static var weekday: UIColor { return largeTitle.adjusted(alpha: 0.5) }
    static var dateOffCurrentMonth: UIColor { return largeTitle.adjusted(alpha: 0.4) }
    static var unselectableDate: UIColor { return largeTitle.adjusted(alpha: 0.2) }
}

extension UIColor: Theme {
    
    static var theme: Theme.Type = Dark.self

    static let statusBarStyle: UIStatusBarStyle = theme.statusBarStyle
    static let keyboardAppearance: UIKeyboardAppearance = theme.keyboardAppearance
    static let blurStyle: UIBlurEffect.Style = theme.blurStyle
    
    static let defaultGradient: [CGColor] = theme.defaultGradient
    static let largeTitle: UIColor = theme.largeTitle
    static let tagsBackground: UIColor = theme.tagsBackground
    static let background: UIColor = theme.background
    static let placeholder: UIColor = theme.placeholder
    static let shadow: CGColor = theme.shadow
    
    static let doneButtonBackground: UIColor = theme.doneButtonBackground
    
    // MARK: - Cell
    static let iconCellIcon: UIColor = theme.iconCellIcon
    static let taskTitleLabel: UIColor = theme.taskTitleLabel
    static let cellTagLabel: UIColor = theme.cellTagLabel
    static let cellIcons: UIColor = theme.cellIcons
    static let deleteRed: UIColor = theme.deleteRed
    static let completeGreen: UIColor = theme.completeGreen
    static let uncompleteYellow: UIColor = theme.uncompleteYellow
    
    // MARK: - Calendar
    static let deselectedDateBackground: UIColor = theme.deselectedDateBackground
    static let selectedDateBackground: UIColor = theme.selectedDateBackground
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
