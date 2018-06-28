//
//  Description.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 14/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

struct Description: Storable, Equatable {
    
    enum `Type`: Equatable {
        case note
        case checklist
    }
    
    enum Status: Equatable {
        case complete
        case incomplete
    }
    
    var uuid: UUID
    var text: String
    var type: Type
    var status: Status
    
    init(text: String = "", type: Type = .note, status: Status = .incomplete) {
        self.uuid = UUID()
        self.text = text
        self.type = type
        self.status = status
    }
}
