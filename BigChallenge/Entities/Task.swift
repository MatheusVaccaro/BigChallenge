//
//  Task.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

struct Task: Storable {
    
    enum Status {
        case complete
        case incomplete
    }
    
    var title: String
    var status: Status
    
    init(title: String = "", status: Status = .incomplete) {
        self.title = title
        self.status = status
    }
    
}
