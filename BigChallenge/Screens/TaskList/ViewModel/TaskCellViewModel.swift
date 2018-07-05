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
    
    var status: String {
        if task.isCompleted { return String.taskCellComplete }
        else { return String.taskCellIncomplete }
    }
    
    func shouldChangeTask(title: String) {
        task.title = title
    }
    
    func changedCheckButton(to bool: Bool) {
        task.isCompleted = bool
    }
}
