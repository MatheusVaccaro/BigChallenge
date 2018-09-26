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
    
    lazy var tagsDescription: String? = {
        guard !task.tags!.allObjects.isEmpty else { return nil }
        var ans = ""
        
        let tagArray = task.allTags
            .map { $0.title! }
        
        for index in 0..<tagArray.count-1 {
            ans += tagArray[index] + ", "
        }
        
        ans += tagArray.last!
        
        return ans
    }()
    
    func dateString(with format: String) -> String? {
        guard let date = task.dates.min() else { return nil }
    
        return date.string(with: format)
    }
    
    lazy var accessibilityDateString: String? = {
        guard let date = task.dates.min() else { return nil }
        
        return date.accessibilityDescription
    }()
    
    var checkButtonGradient: [CGColor] {
        return task.allTags.first?.colors
            ?? [UIColor.black.cgColor, UIColor.black.cgColor]
    }
    
    func changedCheckButton(to bool: Bool) {
        task.isCompleted = true //TODO: refactor
        task.completionDate = Date()
        
        taskObservable.onNext(task)
    }
    
    // MARK: - Accessibility
    lazy var locationDescription: String? = {
        guard !task.locations.isEmpty else { return nil }
        
        return "set to \(task.locations.count) locations" //TODO: localize
    }()
    
    let voiceOverHint: String = "dica" //TODO: tap to complete / uncomplete
    let editActionTitle: String = "editar"
    let deleteActionTitle: String = "deletar"
}
