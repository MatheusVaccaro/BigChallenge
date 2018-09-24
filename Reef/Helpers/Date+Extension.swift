//
//  Date+Extension.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 21/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Date {
    static func now() -> Date {
		return DateGenerator.shared?.now ?? Date()
    }
    
    func string(with format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        let dateStr = dateFormatter.string(from: self)
        
        return dateStr
    }
    
    var accessibilityDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .full
        let dateStr = dateFormatter.string(from: self)
        
        return dateStr
    }
}

class DateGenerator {
    
    static var shared: DateGenerator?
    let now: Date
    
    init(currentDate: Date) {
        self.now = currentDate
    }
}
