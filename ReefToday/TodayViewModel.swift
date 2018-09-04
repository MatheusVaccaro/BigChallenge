//
//  TodayViewModel.swift
//  ReefToday
//
//  Created by Bruno Fulber Wide on 31/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol TodayViewModelDelegate: class {
    func removedTasks(at row: Int)
    func reloadedTasks()
}

class TodayViewModel {
    
    weak var delegate: TodayViewModelDelegate?
    private var tasks: [Task]
    
    private let reef = ReefKit()
    
    init() {
        self.tasks = []
        reef.fetchTasks() { tasks in
            self.tasks = ReefKit.recommendedTasks(from: tasks)
            self.delegate?.reloadedTasks()
        }
    }
    
    var numberOfTasks: Int {
        return tasks.count
    }
    
    func task(for index: Int) -> Task {
        return tasks[index]
    }
    
    func completed(_ task: Task) {
        if let index = tasks.index(of: task) {
            reef.save(task)
            tasks.remove(at: index)
            delegate?.removedTasks(at: index)
        }
    }
}
