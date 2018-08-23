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
import ReefKit

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
        
        let tagArray = task.allTags
            .map { $0.title! }
        
        for index in 0..<tagArray.count-1 {
            ans += tagArray[index] + ", "
        }
        
        ans += tagArray.last!
        
        return ans
    }()
    
    var checkButtonGradient: [CGColor] {
        return task.allTags.first!.colors
    }
    
    func changeTextTitle(to title: String) {
        let attributes: [TaskAttributes : Any] = [.title: title]
        taskModel.update(task, with: attributes)
        taskModel.save(task)
    }
    
    func changedCheckButton(to bool: Bool) {
        let attributes: [TaskAttributes : Any] = [.isCompleted: bool,
                                                        .completionDate: Date()]
        taskModel.update(task, with: attributes)
        let metricAttributes =
            ["time to complete" : task.creationDate!.timeIntervalSinceNow]
        if bool {
            Answers.logCustomEvent(withName: "completed task", customAttributes: metricAttributes)
        }
    }
}
