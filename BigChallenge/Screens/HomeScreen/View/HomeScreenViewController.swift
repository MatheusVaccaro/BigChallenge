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
    
    var viewModel: HomeScreenViewModel!
    var selectedTags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(gradientLayer) // background gradient layer
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        observeSelectedTags()
        observeClickedAddTag()
        setupNSUserActivity()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateContentSize),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNSUserActivity() {
        let activity = NSUserActivity(activityType: "com.bigBeanie.finalChallenge.selectedTags")
        
        activity.isEligibleForPublicIndexing = true
        
        //restore
        activity.userInfo = ["selectedTags": selectedTags]
        
        //search
        activity.isEligibleForSearch = true
        activity.keywords = Set<String>(selectedTags.map { $0.title! })
        
        activity.isEligibleForHandoff = true
        
        //siri shortcut
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        }
        
        userActivity = activity
    }
    
    @objc fileprivate func updateContentSize() {
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
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
                    viewModel.tagCollectionViewModel(with: selectedTags) //TODO add option to open with selected tags
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
                self.selectedTags = event.element ?? []
                if let activity = self.userActivity { self.updateUserActivityState(activity) }
                self.taskListViewController.viewModel.filterTasks(with: event.element!)
                print("selected tags are: \(event.element!.map { $0.title })")
            }.disposed(by: disposeBag)
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.userInfo!["selectedTags"] = selectedTags
        activity.keywords =
            Set<String>(selectedTags.map { $0.title! })
        
        activity.title =
            selectedTags.map { $0.title! }.description
        
        print(activity.keywords)
        activity.becomeCurrent()
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
