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

class HomeScreenViewController: UIViewController {
    
    weak var delegate: HomeScreenViewModelDelegate?
    var viewModel: HomeScreenViewModel!
    
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var bigTitle: UILabel!

    fileprivate var taskListViewController: TaskListViewController!
    fileprivate var tagCollectionViewController: TagCollectionViewController!

    private let disposeBag = DisposeBag()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.frame = view.frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = UIColor.backGroundGradient
        layer.zPosition = -1
        
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(gradientLayer) // background gradient layer
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        observeSelectedTags()
        observeClickedAddTag()
        userActivity = viewModel.userActivity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bigTitle.font =
            UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            if let taskListViewController = segue.destination as? TaskListViewController {
                let taskListViewModel = viewModel.taskListViewModel
                taskListViewModel.shouldAddTask.subscribe { event in
                    if let shouldAddTask = event.element {
                        if shouldAddTask {
                            self.delegate?
                                .willAddTask(selectedTags: self.tagCollectionViewController.viewModel.selectedTags )
                        }
                    }
                }.disposed(by: disposeBag)
                taskListViewController.viewModel = taskListViewModel
                self.taskListViewController = taskListViewController
            }
        } else if segue.identifier == "tagCollectionSegue" {
            if let tagCollectionViewController = segue.destination as? TagCollectionViewController {
                let tagCollectionViewModel =
                    viewModel.tagCollectionViewModel(with: viewModel.selectedTags)
                tagCollectionViewController.viewModel = tagCollectionViewModel
                self.tagCollectionViewController = tagCollectionViewController
            }
        }
    }
    
    fileprivate func observeClickedAddTag() {
        tagCollectionViewController.addTagEvent?.subscribe { _ in
            self.delegate?.willAddTag()
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeSelectedTags() {
        tagCollectionViewController.viewModel.selectedTagsObservable
            .subscribe { event in
                self.viewModel.updateSelectedTagsIfNeeded(event.element)
                if let activity = self.userActivity { self.updateUserActivityState(activity) }
                self.taskListViewController.viewModel.filterTasks(with: event.element!)
            }.disposed(by: disposeBag)
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        viewModel.updateUserActivity(activity)
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
