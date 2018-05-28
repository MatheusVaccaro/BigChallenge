//
//  TaskCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class TaskCellViewModel {
    
    private let task: Task
    
    init(task: Task) {
        self.task = task
    }
    
    var title: String {
        return task.title
    }
    
    var status: String {
        switch task.status {
        case .complete:
            return "complete"
        case .incomplete:
            return "incomplete"
        }
    }
    
}
