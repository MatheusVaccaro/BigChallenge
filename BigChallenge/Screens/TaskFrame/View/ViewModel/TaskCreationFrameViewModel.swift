//
//  CreationFrameView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import Crashlytics
import CoreLocation
import RxSwift

class TaskCreationFrameViewModel: CreationFrameViewModelProtocol {
    fileprivate var taskModel: TaskModel
    fileprivate var taskTitle: String? {
        didSet {
            doneButtonObservable.onNext(shouldEnableDoneButton)
        }
    }
    fileprivate var taskTags: [Tag]?
    fileprivate var taskNotes: String?
    fileprivate var taskRegion: CLCircularRegion?
    fileprivate var taskArriving: Bool?
    fileprivate var taskDueTimeOfDay: DateComponents?
    fileprivate var taskDueDate: DateComponents?
    fileprivate var taskFrequency: NotificationOptions.Frequency?
    
    var task: Task? {
        didSet {
            taskTitle = task!.title
        }
    }
    
    let doneButtonObservable: BehaviorSubject<Bool>
    
    weak var delegate: CreationFrameViewModelDelegate?
    
    init(mainInfoViewModel: NewTaskViewModel,
         detailViewModel: MoreOptionsViewModel,
         taskModel: TaskModel) {
        self.taskModel = taskModel
        doneButtonObservable = BehaviorSubject<Bool>(value: false)
        mainInfoViewModel.outputDelegate = self
        detailViewModel.delegate = self
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        if let task = task {
            updateTask()
        } else {
            createTaskIfPossible()
        }
        delegate?.didTapSaveButton()
    }
    
    var canCreateTask: Bool {
        guard taskTitle != nil else { return false }
        return true
    }
    
    private var taskAttributes: [TaskModel.Attributes : Any] {
        var attributes: [TaskModel.Attributes : Any] = [:]
            
        if let taskTitle = taskTitle { attributes[.title] = taskTitle }
        if let taskTags = taskTags {
            attributes[.tags] = taskTags
            taskAnswersAttributes["tags"] = taskTags.count
        }
        if let taskNotes = taskNotes {
            attributes[.notes] = taskNotes
            taskAnswersAttributes["notes"] = true
        }
        if let taskArriving = taskArriving { attributes[.arriving] = taskArriving }
        if let region = taskRegion {
            attributes[.region] = region
            Answers.logCustomEvent(withName: "added region on task")
            taskAnswersAttributes["region"] = true
        }
        
        if let taskDueDate = self.taskDueDate {
            
            var taskDueTimeOfDay = self.taskDueTimeOfDay
            let date = Calendar.current.combine(date: taskDueDate, andTimeOfDay: taskDueTimeOfDay)!
            attributes[.dueDate] = date
            
            taskAnswersAttributes["date"] = true
            taskAnswersAttributes["dateDistanceFromNow"] = date.timeIntervalSinceNow
        }
        
        return attributes
    }
    
    var taskAnswersAttributes: [String : Any] = [
        "date" : false,
        "region" : false,
        "notes" : false,
        "tags" : false
    ]
    
    private func updateTask() {
        guard canCreateTask else { return }
        taskModel.update(task!, with: taskAttributes)
        Answers.logCustomEvent(withName: "updated task", customAttributes: taskAnswersAttributes)
    }
    
    private func createTaskIfPossible() {
        guard canCreateTask else { return }
        let task = taskModel.createTask(with: taskAttributes)
        taskModel.save(task)
        Answers.logCustomEvent(withName: "created task", customAttributes: taskAnswersAttributes)
    }
    
    private var shouldEnableDoneButton: Bool {
        guard let taskTitle = taskTitle else { return false }
        return !taskTitle.isEmpty
    }
   
}

extension TaskCreationFrameViewModel: NewTaskViewModelOutputDelegate {
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?) {
        taskTitle = title
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTags tags: [Tag]?) {
        taskTags = tags ?? []
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateNotes notes: String?) {
        taskNotes = notes ?? ""
    }
}

extension TaskCreationFrameViewModel: MoreOptionsViewModelDelegate {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool) {
        taskRegion = location
        taskArriving = arriving
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents) {
        taskDueDate = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents) {
        taskDueTimeOfDay = timeOfDay
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
        taskFrequency = frequency
    }
}
