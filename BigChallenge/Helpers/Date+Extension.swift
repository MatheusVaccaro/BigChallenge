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
}

class DateGenerator {
    
    static var shared: DateGenerator?
    let now: Date
    
    init(currentDate: Date) {
        self.now = currentDate
    }
}
