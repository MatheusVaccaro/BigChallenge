//
//  CalendarView.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol CalendarViewAccessibilityProvider: class {
    func scrollDate(forwards: Bool)
    func scrollMonth(forwards: Bool)
    func accessibilityValue() -> String?
}

class CalendarView: UIView {
    weak var accessibilityProvider: CalendarViewAccessibilityProvider?
    
    override var accessibilityLabel: String? {
        get {
            return Strings.DateInputView.VoiceOver.label
        }
        set { }
    }
    
    override var accessibilityHint: String? {
        get {
            return Strings.DateInputView.VoiceOver.hint
        }
        set { }
    }
    
    override var accessibilityValue: String? {
        get {
            return accessibilityProvider?.accessibilityValue()
        }
        set { }
    }
    
    override func accessibilityIncrement() {
        accessibilityProvider?.scrollDate(forwards: true)
    }
    
    override func accessibilityDecrement() {
        accessibilityProvider?.scrollDate(forwards: false)
    }
    
    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        switch direction {
        case .left:
            accessibilityProvider?.scrollMonth(forwards: true)
            return true
        case .right:
            accessibilityProvider?.scrollMonth(forwards: false)
            return true
        default:
            return false
        }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.adjustable
        }
        set { }
    }
}
