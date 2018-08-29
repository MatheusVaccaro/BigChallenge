//
//  TaskListViewModel.swift
//  Reef
//
//  Created by Max Zorzetti on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskListViewModel {
    var tasksObservable: BehaviorSubject<([Task], [Task])> { get set }
    var taskCompleted: PublishSubject<Task> { get set }
    var shouldAddTask: PublishSubject<Bool> { get set }
    var shouldEditTask: PublishSubject<Task> { get set }
    var showsCompletedTasks: Bool { get set }
    var tasksToShow: [Task] { get }
    
    var mainTasks: [Task] { get }
    var secondaryTasks: [Task] { get }
    var completedTasks: [Task] { get }
    var selectedTags: [Tag] { get }
    
    var recommendedHeaderTitle: String { get }
    var section2HeaderTitle: String { get }
    
    init(model: TaskModel)
    
    func filterTasks(with tags: [Tag])
    func taskCellViewModel(for task: Task) -> TaskCellViewModel
    func shouldGoToAddTask()
    func shouldGoToEdit(_ task: Task)
}
