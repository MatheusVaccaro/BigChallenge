//
//  TaskListViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: TaskListViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil
        tableView.delegate = nil
        
        // config tableView to autolayout constraints to resize the tableCells height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        configureWithViewModel()
        bindTableView()
    }
    
    private func configureWithViewModel() {
        
    }
    
    private func bindTableView() {
        viewModel.tasksObservable
            .bind(to: tableView.rx.items(cellIdentifier: TaskTableViewCell.identifier,
                                         cellType: TaskTableViewCell.self)) { (_, task, cell) in
                                            
                print("reloaded cell for task \(task.title ?? "none")")
                let taskCellViewModel = self.viewModel.taskCellViewModel(for: task)
                taskCellViewModel.taskObservable.subscribe {
                    if let task = $0.element {
                        self.viewModel.taskCompleted.onNext(task)
                    }
                }.disposed(by: self.disposeBag)
                cell.configure(with: taskCellViewModel)
                cell.delegate = self
            }.disposed(by: disposeBag)
        
        tableView.rx.didEndDragging.subscribe { _ in
            if self.tableView.contentOffset.y < -50.0 {
                self.viewModel.shouldGoToAddTask()
            }
        }.disposed(by: disposeBag)
    }
}
extension TaskListViewController: TaskCellDelegate {
    func shouldUpdateSize(of cell: TaskTableViewCell) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

// MARK: - StoryboardInstantiable
extension TaskListViewController: StoryboardInstantiable {
    
    static var viewControllerID: String {
        return "TaskListViewController"
    }
    
    static var storyboardIdentifier: String {
        return "TaskList"
    }
}
