//
//  TaskListViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: TaskListViewModel?
    private var editBarButtonItem: UIBarButtonItem?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        setupEditBarButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapAddBarButtonItem(_ sender: Any) {
        viewModel?.didTapAddButton()
    }
    
    // MARK: - Functions
    
    // The default editButtonItem was not toggling the tableview's edition mode, so we coded it from scratch
    private func setupEditBarButtonItem() {
        let editBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditionMode))
        self.editBarButtonItem = editBarButtonItem
        navigationItem.leftBarButtonItem = editBarButtonItem
    }
    
    @objc private func toggleEditionMode() {
        let barButtonItem: UIBarButtonItem
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            barButtonItem =
                UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditionMode))
        } else {
            tableView.setEditing(true, animated: true)
            barButtonItem =
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditionMode))
        }
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
}
// MARK: - StoryboardInstantiable

extension TaskListViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return "TaskListViewController"
    }
    
    static var storyboardName: String {
        return "TaskList"
    }
    
}
// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
            let task = viewModel.taskForRowAt(indexPath: indexPath),
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        let taskCellViewModel = TaskCellViewModel(task: task)
        cell.configure(with: taskCellViewModel)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.isEditing {
            viewModel?.didSelectTask(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // swiftlint:disable:next line_length
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.removeTask(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
