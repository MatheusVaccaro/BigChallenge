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
    private var barButtonItem: UIBarButtonItem!
    private let disposeBag = DisposeBag()
    
    lazy var editBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditionMode))
    }()
    lazy var doneBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditionMode))
    }()
    
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
    
    override public func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    @IBAction func didTapAddBarButtonItem(_ sender: Any) {
        viewModel?.didTapAddButton()
    }
    
    // MARK: - Functions
    // The default editButtonItem was not toggling the tableview's edition mode, so we coded it from scratch
    private func configureWithViewModel() {
        let editBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .edit,
                            target: self,
                            action: #selector(toggleEditionMode))
        
        self.barButtonItem = editBarButtonItem
        navigationItem.leftBarButtonItem = editBarButtonItem
        
        if let viewModel = viewModel {
            navigationItem.title = viewModel.viewTitle
        }
    }
    
    private func bindTableView() {
        guard let viewModel = viewModel else { return }
        viewModel.tasksObservable
            .bind(to: tableView.rx.items(cellIdentifier: TaskTableViewCell.identifier,
                                           cellType: TaskTableViewCell.self)) { (_, task, cell) in
                                            
                print("reloaded cell for task \(task.title)")
                let taskCellViewModel = viewModel.createCellViewModel(for: task)
                cell.configure(with: taskCellViewModel)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func toggleEditionMode() {
        let barButtonItem: UIBarButtonItem
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            barButtonItem = editBarButtonItem
        } else {
            tableView.setEditing(true, animated: true)
            barButtonItem = doneBarButtonItem
        }
        navigationItem.leftBarButtonItem = barButtonItem
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

// MARK: - UITableViewDelegate

//extension TaskListViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if tableView.isEditing {
//            viewModel?.didSelectTask(at: indexPath)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            viewModel?.removeTask(at: indexPath)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
//}

extension TaskListViewController: TaskCellDelegate {
    func shouldUpdateSize(of cell: TaskTableViewCell) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
