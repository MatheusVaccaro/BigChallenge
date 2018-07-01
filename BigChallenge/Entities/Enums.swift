//
//  Task.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public enum TaskStatus: Int16 {
    case complete = 0
    case incomplete = 1
}

public enum DescriptionType: Int16 {
    case note = 0
    case checklist = 1
}

public enum TagColors: Int16 {
    case red = 0
}
