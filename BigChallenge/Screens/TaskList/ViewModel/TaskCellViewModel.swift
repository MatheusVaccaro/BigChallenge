//
//  TaskCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class TaskCellViewModel {
    
    var taskIsCompleted: Bool { return task.isCompleted }
    
    var taskObservable: PublishSubject<Task>
    
    private var task: Task
    
    init(task: Task) {
        self.task = task
        taskObservable = PublishSubject<Task>()
    }
    
    var title: String {
        return task.title!
    }
    
    var checkButtonGradient: [CGColor] {
        let index = (task.tags?.allObjects.first as? Tag)?.color ?? 0
        return TagModel.tagColors[Int(index)]
    }
    
    func shouldChangeTask(title: String) {
        task.title = title
        taskObservable.onNext(task)
    }
    
    func changedCheckButton(to bool: Bool) {
        task.isCompleted = bool
        taskObservable.onNext(task)
    }
}
