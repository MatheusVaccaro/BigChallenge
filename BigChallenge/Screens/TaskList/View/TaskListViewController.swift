//
//  TaskListViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct SectionedTaskModel {
    var items: [Task]
}

extension SectionedTaskModel: SectionModelType {
    init(original: SectionedTaskModel, items: [Task]) {
        self = original
        self.items = items
    }
    
    typealias Item = Task
}

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
        
        bindTableView()
    }
    
    private func bindTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionedTaskModel>(
            configureCell: {(dataSource, table, indexPath, task) in
                let cell = table.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
                
                let taskCellViewModel = self.viewModel.taskCellViewModel(for: task)
                
                taskCellViewModel.taskObservable.subscribe {
                    if let task = $0.element {
                        self.viewModel.taskCompleted.onNext(task)
                    }
                }.disposed(by: self.disposeBag)
                
                cell.configure(with: taskCellViewModel)
                cell.delegate = self
                
                return cell
            })

        tableView.rx.didEndDragging.subscribe { _ in
            if self.tableView.contentOffset.y < -50.0 {
                self.viewModel.shouldGoToAddTask()
            }
        }.disposed(by: disposeBag)
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            if index == 0 {
                return ""
            } else {
                return "Also Tagged:"
            }
        }
        
        viewModel.tasksObservable
            .map { return [SectionedTaskModel(items: $0.0), SectionedTaskModel(items: $0.1)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
