//
//  TaskCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift
import ReefKit

public class TaskCellViewModel {
    
    var taskIsCompleted: Bool { return task.isCompleted }
    
    public var taskObservable: PublishSubject<Task>
    
    private var task: Task
    
    public init(task: Task) {
        self.task = task
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
        return task.allTags.first?.colors
            ?? [UIColor.black.cgColor, UIColor.black.cgColor]
    }
    
    func changeTextTitle(to title: String) {
        let attributes: [TaskAttributes : Any] = [.title: title]
//        taskModel.update(task, with: attributes)
//        taskModel.save(task)
    }
    
    func changedCheckButton(to bool: Bool) {
        let attributes: [TaskAttributes : Any] = [.isCompleted: bool,
                                                        .completionDate: Date()]
        task.isCompleted = true
        task.completionDate = Date()
        
        taskObservable.onNext(task)
    }
}
