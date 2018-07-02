//
//  TaskCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class TaskCellViewModel {
    
    private var task: Task
    private let model: TaskModel
    
    init(task: Task, model: TaskModel) {
        self.task = task
        self.model = model
    }
    
    var title: String {
        return task.title!
    }
    
    //TODO: this looks awful
    var status: String {
        switch task.status {
        case TaskStatus.complete.rawValue:
            return String.taskCellComplete
        default:
            return String.taskCellIncomplete
        }
    }
    
    func shouldChangeTask(title: String) {
        task.title = title
    }
    
    func shouldCompleteTask(_ bool: Bool) {
        if bool {
            task.status = TaskStatus.complete.rawValue
        } else {
            task.status = TaskStatus.incomplete.rawValue
        }
    }
}
