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
    
    lazy var title: String = {
        return task.title!
    }()
    
    lazy var tagsDescription: String = {
        guard !task.tags!.allObjects.isEmpty else { return " " }
        var ans = ""
        
        let tagArray = (task.tags?.allObjects as! [Tag]).map { $0.title ?? "nil" }
        
        for index in 0..<tagArray.count-1 {
            ans += tagArray[index] + ", "
        }
        
        ans += tagArray.last!
        
        return ans
    }()
    
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
