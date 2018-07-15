//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol HomeScreenViewModelDelegate: class {
    func willAddTask()
    func wilEditTask()
}

class HomeScreenViewController: UIViewController {
    
    weak var delegate: HomeScreenViewModelDelegate?
    
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    
    fileprivate var taskListViewController: TaskListViewController!
    fileprivate var tagCollectionViewController: TagCollectionViewController!
    
    var viewModel: HomeScreenViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.tagModel.didAddTags = { _ in
//            self.taskListViewController.filterTasks(with: nil)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            if let taskListViewController = segue.destination as? TaskListViewController {
                let taskListViewModel = viewModel.taskListViewModel
                taskListViewModel.delegate = self
                taskListViewController.viewModel = taskListViewModel
                self.taskListViewController = taskListViewController
            }
        } else if segue.identifier == "tagCollectionSegue" {
            if let tagCollectionViewController = segue.destination as? TagCollectionViewController {
                let tagCollectionViewModel = viewModel.tagListViewModel
                tagCollectionViewController.delegate = self
                tagCollectionViewController.viewModel = tagCollectionViewModel
                self.tagCollectionViewController = tagCollectionViewController
            }
        }
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        delegate?.willAddTask()
    }
}

extension HomeScreenViewController: TaskListViewModelDelegate {
    func didSelectTask(_ task: Task) {
        //TODO
    }
}

extension HomeScreenViewController: TagCollectionDelegate {
    
}

extension HomeScreenViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "HomeScreenViewController"
    }
    
    static var storyboardIdentifier: String {
        return "HomeScreen"
    }
}
