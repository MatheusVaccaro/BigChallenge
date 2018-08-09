//
//  CreationFrameView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

protocol CreationFrameViewModelDelegate: class {
    func didTapCancelButton()
    func didTapSaveButton()
}

class CreationFrameViewModel {
    
    fileprivate var taskModel: TaskModel
    fileprivate var taskTitle: String? {
        didSet {
            doneButtonObservable.onNext(shouldEnableDoneButton)
        }
    }
    fileprivate var taskTags: [Tag] = []
    fileprivate var taskNotes: String = ""
    fileprivate var taskRegion: CLCircularRegion?
    fileprivate var taskArriving: Bool = false
    fileprivate var taskDueTimeOfDay: DateComponents?
    fileprivate var taskDueDate: DateComponents?
    fileprivate var taskFrequency: NotificationOptions.Frequency?
    
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
    
    var canCreateTask: Bool {
        guard taskTitle != nil else { return false }
        return true
    }
    
    private func createTaskIfPossible() {
        guard let taskTitle = taskTitle else { return }
        
        var attributes: [TaskModel.Attributes : Any] = [
            .title : taskTitle,
            .tags : taskTags,
            .notes : taskNotes,
            .arriving : taskArriving
        ]
        
        if let taskDueDate = self.taskDueDate,
           let taskDueTimeOfDay = self.taskDueTimeOfDay,
           let date = Calendar.current.combine(date: taskDueDate, andTimeOfDay: taskDueTimeOfDay) {
            attributes[.dueDate] = date
        }
        if let region = taskRegion {
            attributes[.region] = region
        }
        
        let task = taskModel.createTask(with: attributes)
        taskModel.save(task)
        NotificationManager.addLocationNotification(for: task)
    }
}

extension CreationFrameViewModel: NewTaskViewModelOutputDelegate {
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?) {
        taskTitle = title
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTags tags: [Tag]?) {
        taskTags = tags ?? []
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateDueDate dueDate: Date?) {
//        taskDueDate = dueDate
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateNotes notes: String?) {
        taskNotes = notes ?? ""
    }
}

extension CreationFrameViewModel: MoreOptionsViewModelDelegate {
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

extension CreationFrameViewModel: CreationFrameViewModelProtocol {
    
    fileprivate var shouldEnableDoneButton: Bool {
        guard let taskTitle = taskTitle else { return false }
        return !taskTitle.isEmpty
    }

    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        createTaskIfPossible()
        delegate?.didTapSaveButton()
    }
    
}
