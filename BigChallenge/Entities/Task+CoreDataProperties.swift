//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Bruno Fulber Wide on 02/07/18.
//
//

import Foundation
import CoreData


extension Task {

    var status: TaskStatus {
        get {
            return TaskStatus(rawValue: statusRaw)!
        }
        set {
            self.statusRaw = newValue.rawValue
        }
    }
}
