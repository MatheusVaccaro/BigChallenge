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

protocol TaskCellViewModelDelegate: class {
    func shouldEdit(_ task: Task)
}

public class TaskCellViewModel {
    
    private let model: TaskModel
    private var task: Task
    weak var delegate: TaskCellViewModelDelegate?
    
    public init(task: Task, taskModel: TaskModel) {
        self.task = task
        self.model = taskModel
    }
    
    var taskIsPrivate: Bool {
        return task.isPrivate
    }
    
    var isTaskLate: Bool {
        return task.isLate
    }
    
    var shouldShowLocationIcon: Bool {
        return !task.locations.isEmpty
    }
    
    var shouldShowDateIcon: Bool {
        return !task.dates.isEmpty
    }
    
    lazy var title: String = { return task.title! }()
    var taskIsCompleted: Bool { return task.isCompleted }
    
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
        if let date = task.nextDate {
            return date.string(with: format)
        } else if let date = task.firstLateDate {
            return date.string(with: format)
        } else {
            return nil
        }
    }
    
    var checkButtonGradient: [CGColor] {
        return task.allTags.first?.colors ?? ReefColors.defaultGradient
    }
    
    func edit() {
        delegate?.shouldEdit(task)
    }
    
    func delete() {
        model.delete(task)
    }
    
    func toggleCompleteTask() {
        var information: TaskInformation = [ .isCompleted : !task.isCompleted ]
        if !task.isCompleted { information[.completionDate] = Date() }
        
        model.update(task, with: information)
    }
    
    // MARK: - Accessibility
    lazy var locationDescription: String? = {
        guard !task.locations.isEmpty else { return nil }
        
        let localizedString = Strings.Task.Cell.VoiceOver.locationDescription
        
        return String.localizedStringWithFormat(localizedString,
                                                String(describing: task.locations.count))
    }()
    
    lazy var accessibilityDateString: String? = {
        guard let date = task.dates.min() else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        let dateDescription = dateFormatter.string(from: date)
        
        let localizedString = Strings.Task.Cell.VoiceOver.dateDescription
        
        return String.localizedStringWithFormat(localizedString,
                                                dateDescription)
    }()
    
    // MARK: - String
    var voiceOverHint: String = Strings.Task.Cell.VoiceOver.hint
    var completeActionTitle: String {
        return !task.isCompleted
            ? Strings.General.completeActionTitle
            : Strings.General.notCompletedActionTitle
    }
    let deleteActionTitle: String = Strings.General.deleteActionTitle
}
