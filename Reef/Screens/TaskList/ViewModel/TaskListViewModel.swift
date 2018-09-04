//
//  TaskListViewModel.swift
//  Reef
//
//  Created by Max Zorzetti on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit
import ReefTableViewCell
import RxSwift

protocol TaskListViewModel {

    var tasksObservable: BehaviorSubject<[[Task]]> { get set }
    var taskCompleted: PublishSubject<Task> { get set }
    var shouldAddTask: PublishSubject<Bool> { get set }
    var shouldEditTask: PublishSubject<Task> { get set }
    
    var sections: [[Tag]] { get }
    var tasks: [[Task]] { get }
    var selectedTags: [Tag] { get }
    var relatedTags: [Tag] { get }

    var isShowingRecommendedSection: Bool { get }
    var isShowingCard: Bool { get }
    
    var recommendedHeaderTitle: String { get }
    var section2HeaderTitle: String { get }
    
    init(model: TaskModel)
    
    func task(for indexPath: IndexPath) -> Task
    func tags(forHeadersInSection section: Int) -> [Tag]
    func hasHeaderInSection(_ section: Int) -> Bool
    func isCardSection(_ section: Int) -> Bool
    func filterTasks(with selectedTags: [Tag], relatedTags: [Tag])
    func taskCellViewModel(for task: Task) -> TaskCellViewModel
    func shouldGoToAddTask()
    func shouldGoToEdit(_ task: Task)
    func completeTask(taskID: UUID)
}
