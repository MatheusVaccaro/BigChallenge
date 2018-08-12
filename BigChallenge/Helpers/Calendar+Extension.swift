//
//  Calendar+Extension.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Calendar {
    func date(from dateComponents: DateComponents?) -> Date? {
        guard let dateComponents = dateComponents else { return nil }
        
        return date(from: dateComponents)
    }
}
