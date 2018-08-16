//
//  TaskCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import Crashlytics
import RxCocoa
import RxSwift

class TaskCellViewModel {
    
    var taskIsCompleted: Bool { return task.isCompleted }
    
    var taskObservable: PublishSubject<Task>
    
    private var task: Task
    private var taskModel: TaskModel
    
    init(task: Task, taskModel: TaskModel) {
        self.task = task
        self.taskModel = taskModel
        taskObservable = PublishSubject<Task>()
    }
    
    lazy var title: String = {
        return task.title!
    }()
    
    lazy var tagsDescription: String = {
        guard !task.tags!.allObjects.isEmpty else { return "" }
        var ans = ""
        
        let tagArray = (task.tags?.allObjects as! [Tag]).map { $0.title ?? "nil" }
        
        for index in 0..<tagArray.count-1 {
            ans += tagArray[index] + ", "
        }
        
        ans += tagArray.last!
        
        return ans
    }()
    
    var checkButtonGradient: [CGColor] {
        let index = (task.tags?.allObjects.first as? Tag)?.colorIndex ?? 0
        return TagModel.tagColors[Int(index)]
    }
    
    func changeTextTitle(to title: String) {
        let attributes: [TaskModel.Attributes : Any] = [.title: title]
        taskModel.update(task, with: attributes)
        taskModel.save(task)
    }
    
    func changedCheckButton(to bool: Bool) {
        let attributes: [TaskModel.Attributes : Any] = [.isCompleted: bool,
                                                        .completionDate: Date()]
        taskModel.update(task, with: attributes)
        taskModel.save(task)
        let metricAttributes =
            ["time to complete" : task.creationDate!.timeIntervalSinceNow]
        if bool {
            Answers.logCustomEvent(withName: "completed task", customAttributes: metricAttributes)
            taskModel.deindex(task: task)
        }
    }
}
