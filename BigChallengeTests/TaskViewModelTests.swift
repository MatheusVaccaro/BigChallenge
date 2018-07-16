//
//  TaskViewModelTests.swift
//  BigChallengeTests
//
//  Created by Max Zorzetti on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Quick
import Nimble

@testable
import BigChallenge

class TaskListViewModelTests: QuickSpec {
    
    override func spec() {
        
        describe("a TaskListViewModel") {
            var taskListViewModel: TaskListViewModel!
            
            beforeEach {
                let mockPersistence = Persistence(configuration: .inMemory)
                let taskModel = TaskModel(persistence: mockPersistence)
                taskListViewModel = TaskListViewModel(model: taskModel)
            }
            
            describe("title") {
                it("should be localized") {
                    let localizedTitle = String.taskListScreenTitle
                    expect(taskListViewModel.viewTitle).to(equal(localizedTitle))
                }
            }
        }
    }
}
