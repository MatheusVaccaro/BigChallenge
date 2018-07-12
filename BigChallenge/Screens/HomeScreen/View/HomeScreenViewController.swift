//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    
    fileprivate var taskListViewController: TaskListViewController!
    fileprivate var tagCollectionViewController: TagCollectionViewController!
    var taskModel: TaskModel!
    var tagModel: TagModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            if let taskListViewController = segue.destination as? TaskListViewController {
                let taskListViewModel = TaskListViewModel(model: taskModel)
                taskListViewModel.delegate = self
                taskListViewController.viewModel = taskListViewModel
                self.taskListViewController = taskListViewController
            }
        } else if segue.identifier == "tagCollectionSegue" {
            if let tagCollectionViewController = segue.destination as? TagCollectionViewController {
                let tagCollectionViewModel = TagCollectionViewModel(model: tagModel)
                tagCollectionViewController.delegate = self
                tagCollectionViewController.viewModel = tagCollectionViewModel
                self.tagCollectionViewController = tagCollectionViewController
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeScreenViewController: TaskListViewModelDelegate {
    func didTapAddButton() {
        //TODO
    }
    
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
