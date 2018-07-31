////
////  TaskViewModelTests.swift
////  BigChallengeTests
////
////  Created by Max Zorzetti on 16/07/18.
////  Copyright © 2018 Matheus Vaccaro. All rights reserved.
////
//
//import Quick
//import Nimble
//
//@testable
//import BigChallenge
//
//class TaskListViewModelTests: QuickSpec {
//    
//    override func spec() {
//        
//        describe("a TaskListViewModel") {
//            var taskListViewModel: TaskListViewModel!
//            var taskModel: TaskModel!
//            
//            beforeEach {
//                let mockPersistence = Persistence(configuration: .inMemory)
//                taskModel = TaskModel(persistence: mockPersistence)
//                taskListViewModel = TaskListViewModel(model: taskModel)
//                let task = taskModel.createTask(with: "Test Task")
//                taskModel.save(object: task)
//            }
//            
//            describe("list") {
//                it("should be capable of create new tasks") {
//                    let task = taskModel.createTask(with: "Test Task 2")
//                    taskModel.save(object: task)
//                    
//                    expect(taskListViewModel.tasks.contains(task)).to(beTrue())
//                }
//
//                it("should be capable of delete tasks") {
//                    guard let task = taskListViewModel.tasks.first else { return }
//                    taskModel.delete(object: task)
//                    
//                    expect(taskListViewModel.tasks.contains(task)).to(beFalse())
//                }
//                
//                it("should have tasks") {
//                    expect(taskListViewModel.tasks.count).to(beGreaterThan(0))
//                }
//                
//            }
//        }
//    }
//}
