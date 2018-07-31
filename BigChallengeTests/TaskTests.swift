////
////  TaskModelTests.swift
////  BigChallengeTests
////
////  Created by Max Zorzetti on 19/07/18.
////  Copyright © 2018 Matheus Vaccaro. All rights reserved.
////
//
//import Quick
//import Nimble
//
//@testable
//import BigChallenge
//
///*
// Affected user stories:
//    - Create a Task
//     - View a Task
//     - Update a Task
//     - Delete a Task
//*/
//
//class TaskModelTests: QuickSpec {
//
//    override func spec() {
//
//        describe("the TaskModel") {
//            var mockPersistence: Persistence!
//            var taskModel: TaskModel!
//            var taskListViewModel: TaskListViewModel!
//            var newTaskViewModel: NewTaskViewModel!
//            var initialTasks: [Task]!
//            var task: Task!
//
//            beforeEach {
//                mockPersistence = Persistence(configuration: .inMemory)
//                taskModel = TaskModel(persistence: mockPersistence)
//                taskListViewModel = TaskListViewModel(model: taskModel)
//
//                // Setup some mocked tasks
//                let mockTask1 = taskModel.createTask(with: "Mock1")
//                mockTask1.completionDate = Date()
//                mockTask1.dueDate = Date()
//                mockTask1.isCompleted = true
//                taskModel.save(object: mockTask1)
//                taskModel.save(object: taskModel.createTask(with: "Mock1"))
//                taskModel.save(object: taskModel.createTask(with: "Mock2"))
//                taskModel.save(object: taskModel.createTask(with: "Mock3"))
//            }
//
//            describe("creating a task") {
//
//                beforeEach {
//                    newTaskViewModel = NewTaskViewModel(task: nil, isEditing: false, taskModel: taskModel)
//                    newTaskViewModel.taskTitleTextField = "Title"
//                    initialTasks = taskModel.tasks
//                }
//
//                context("when confirming the creation") {
//                    beforeEach {
//                        newTaskViewModel.didTapDoneButton()
//                        // TODO Make this method more testable
//                        task = Set(initialTasks).intersection(taskModel.tasks).first
//                    }
//
//                    it("should create a new task") {
//                        expect(task).toNot(beNil())
//                    }
//
//                    it("should make the task viewable") {
//                        expect(taskListViewModel.tasksToShow).to(contain(task))
//                    }
//
//                    it("should store the task in the model") {
//                        let allTasks = taskModel.tasks
//
//                        expect(allTasks).to(contain(task))
//                    }
//
//                    it("should persist the task") {
//                        let newTaskModel = TaskModel(persistence: mockPersistence)
//                        let allTasks = newTaskModel.tasks
//
//                        expect(allTasks).to(contain(task))
//                    }
//                }
//
//                context("when cancelling the creation") {
//                    beforeEach {
//                        newTaskViewModel.didTapCancelButton()
//                    }
//
//                    it("should not affect the model") {
//                        let allTasks = taskModel.tasks
//
//                        expect(initialTasks).to(equal(allTasks))
//                    }
//
//                    it("should not persist the task") {
//                        let newTaskModel = TaskModel(persistence: mockPersistence)
//                        let allTasks = newTaskModel.tasks
//
//                        // Expect both collections to have the same content
//                        expect(initialTasks).to(contain(allTasks))
//                        expect(allTasks).to(contain(initialTasks))
//                    }
//                }
//            }
//
//            describe("updating a task") {
//                context("saving it") {
//                    it("should update the task in the model") {
//                        // TODO Change this to use the upcoming method taskModel.update(task:)
//                        let task = taskModel.tasks.first!
//                        let initialIsCompleted = task.isCompleted
//                        let initialTitle = task.title!
//                        let initialCompletionDate = task.completionDate
//                        let initialDueDate = task.dueDate
//
//                        task.isCompleted = !initialIsCompleted
//                        task.title = initialTitle + "_changed"
//                        task.completionDate = Date()
//                        task.dueDate = Date()
//
//                        taskModel.save(object: task)
//
//                        expect(task.isCompleted).toNot(equal(initialIsCompleted))
//                        expect(task.title).toNot(equal(initialTitle))
//                        expect(task.completionDate).toNot(equal(initialCompletionDate))
//                        expect(task.dueDate).toNot(equal(initialDueDate))
//                    }
//                }
//
//                context("not saving it") {
//                    it("should not update the task in the model") {
//                        // TODO Implement this using the upcoming method taskModel.update(task:)
//                    }
//                }
//            }
//
//            describe("deleting a task") {
//                context("that is contained in the model") {
//                    it("should remove it from the model") {
//                        let task = taskModel.createTask(with: "Title")
//                        taskModel.save(object: task)
//
//                        taskModel.delete(object: task)
//
//                        expect(taskModel.tasks).notTo(contain(task))
//                    }
//
//                    it("should stop it from persisting") {
//                        let task = taskModel.createTask(with: "Title")
//                        taskModel.save(object: task)
//
//                        taskModel.delete(object: task)
//                        taskModel = nil
//                        let newTaskModel = TaskModel(persistence: mockPersistence)
//
//                        expect(newTaskModel.tasks).notTo(contain(task))
//                    }
//                }
//
//                context("that is not contained in the model") {
//                    it("should not affect the model") {
//                        let unsavedTask = taskModel.createTask(with: "Title")
//                        let previousTasks = taskModel.tasks
//
//                        taskModel.delete(object: unsavedTask)
//
//                        expect(previousTasks).to(equal(taskModel.tasks))
//                    }
//                }
//            }
//        }
//    }
//}
