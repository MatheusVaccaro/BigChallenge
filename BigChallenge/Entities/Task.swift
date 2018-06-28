//
//  Task.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

struct Task: Storable, Equatable {
    
    enum Status: Equatable {
        case complete
        case incomplete
    }
    
    var uuid: UUID
    var title: String
    var status: Status
    var date: Date?
    var descriptions: [Description]
    
    init(title: String = "", status: Status = .incomplete) {
        self.uuid = UUID()
        self.title = title
        self.status = status
        self.descriptions = []
    }
}
