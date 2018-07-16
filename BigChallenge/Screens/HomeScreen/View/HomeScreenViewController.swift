//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

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
    private let disposeBag = DisposeBag()
    
    var viewModel: HomeScreenViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagCollectionViewController.viewModel.selectedTagsObservable.subscribe { event in
            self.taskListViewController.viewModel.filterTasks(with: event.element!)
            print("selected tags are: \( event.element!.map {$0.title} )")
        }.disposed(by: disposeBag)
        print(taskListViewController.viewModel.tasks)
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
//                tagCollectionViewController.delegate = self
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

extension HomeScreenViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "HomeScreenViewController"
    }
    
    static var storyboardIdentifier: String {
        return "HomeScreen"
    }
}
