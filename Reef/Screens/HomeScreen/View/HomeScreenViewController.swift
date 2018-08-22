//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Crashlytics
import RxCocoa
import RxSwift

class HomeScreenViewController: UIViewController {
    
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
    
    lazy var titleGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        
        return layer
    }()
    
    lazy var maskLabel: UILabel = {
        let ans = UILabel()
        
        ans.textAlignment = bigTitle.textAlignment
        ans.font = bigTitle.font
        
        return ans
    }()
    
    lazy var gradientView: UIView = {
        let gradientView = UIView(frame: view.bounds)
        
        gradientView.isUserInteractionEnabled = false
        gradientView.layer.addSublayer(titleGradient)
        gradientView.addSubview(maskLabel)
        gradientView.mask = maskLabel
        
        return gradientView
    }()
    
    override func viewDidLayoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientView.frame = bigTitle.frame
        titleGradient.frame = gradientView.bounds
        maskLabel.frame = gradientView.bounds
        CATransaction.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigTitle.textColor = UIColor.clear
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        view.layer.addSublayer(gradientLayer)
        view.addSubview(gradientView)
        
        setupTagCollection()
        setupTaskList()
        
        configureEmptyState()
        observeSelectedTags()
        observeClickedAddTag()
        userActivity = viewModel.userActivity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        maskLabel.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        configureEmptyState()
    }
    
    private func setupTaskList() {
        let taskListViewModel = viewModel.taskListViewModel
        subscribe(to: taskListViewModel)
        
        taskListViewController = TaskListViewController.instantiate()
        taskListViewController.viewModel = taskListViewModel
        
        addChildViewController(taskListViewController)
		taskListContainerView.addSubview(taskListViewController.view)
        
        NSLayoutConstraint.activate([
            taskListViewController.view.rightAnchor.constraint(equalTo: taskListContainerView.rightAnchor),
            taskListViewController.view.topAnchor.constraint(equalTo: taskListContainerView.topAnchor),
            taskListViewController.view.leftAnchor.constraint(equalTo: taskListContainerView.leftAnchor),
            taskListViewController.view.bottomAnchor.constraint(equalTo: taskListContainerView.bottomAnchor)
        ])
    }
    
    private func setupTagCollection() {
        let tagCollectionViewModel = viewModel.tagCollectionViewModel
        
        tagCollectionViewController = TagCollectionViewController.instantiate()
        tagCollectionViewController.viewModel = tagCollectionViewModel
        
        addChildViewController(tagCollectionViewController)
        tagContainerView.addSubview(tagCollectionViewController.view)
        
        NSLayoutConstraint.activate([
            tagCollectionViewController.view.rightAnchor.constraint(equalTo: tagContainerView.rightAnchor),
            tagCollectionViewController.view.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            tagCollectionViewController.view.leftAnchor.constraint(equalTo: tagContainerView.leftAnchor),
            tagCollectionViewController.view.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor)
        ])
    }
    
    fileprivate func subscribe(to taskListViewModel: TaskListViewModel) {
        taskListViewModel.shouldAddTask.subscribe { event in
            if let shouldAddTask = event.element, shouldAddTask {
                let selectedTags = self.tagCollectionViewController.viewModel.selectedTags
                self.viewModel.delegate?.homeScreenViewModel(self.viewModel,
                                                             willAddTaskWithSelectedTags: selectedTags)
                }
        }.disposed(by: disposeBag)
        
        taskListViewModel.shouldEditTask.subscribe { task in
            if let task = task.element {
                self.viewModel.delegate?.homeScreenViewModel(self.viewModel, willEdit: task)
            }
        }.disposed(by: disposeBag)
        
        taskListViewModel.tasksObservable.subscribe { event in
            guard let tasks = event.element else { return }
            DispatchQueue.main.async {
                self.showEmptyState( tasks.flatMap { $0 }.isEmpty )
            }
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeClickedAddTag() {
        tagCollectionViewController.addTagEvent?.subscribe { _ in
            self.viewModel.delegate?.homeScreenViewModelWillAddTag(self.viewModel)
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeSelectedTags() {
        tagCollectionViewController.viewModel.selectedTagsObservable
            .subscribe { event in
                guard let selectedTags = event.element else { return }
                self.viewModel.updateSelectedTagsIfNeeded(selectedTags)
                self.configureBigTitle()
                let relatedTags = self.tagCollectionViewController.viewModel
                    .filteredTags.filter { !selectedTags.contains($0) }
                self.taskListViewController.viewModel
                    .filterTasks(with: selectedTags,
                                 relatedTags: relatedTags)
                
                if let activity = self.userActivity { self.updateUserActivityState(activity) }
                if !selectedTags.isEmpty {
                    Answers.logCustomEvent(withName: "filtered with tag",
                                           customAttributes: ["numberOfFilteredTags" : selectedTags.count])
                }
                
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Empty State
    @IBOutlet weak var emptyStateImage: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateSubtitleLabel: UILabel!
    @IBOutlet weak var emptyStateOrLabel: UILabel!
    @IBOutlet weak var importFromRemindersButton: UIButton!
    
    fileprivate func showEmptyState(_ bool: Bool) {
        emptyStateSubtitleLabel.isHidden = !bool
        emptyStateTitleLabel.isHidden = !bool
        emptyStateImage.isHidden = !bool
        
        if bool, viewModel.delegate?.homeScreenViewModelShouldShowImportFromRemindersOption(viewModel) ?? false {
            emptyStateOrLabel.isHidden = false
            importFromRemindersButton.isHidden = false
        } else {
            emptyStateOrLabel.isHidden = true
            importFromRemindersButton.isHidden = true
        }
    }
    
    @IBAction func didClickImportFromRemindersButton(_ sender: Any) {
        viewModel.delegate?.homeScreenViewModelWillImportFromReminders(viewModel)
    }
    
    fileprivate func configureEmptyState() {
        emptyStateTitleLabel.font = UIFont.font(sized: 18, weight: .bold, with: .title2)
        emptyStateSubtitleLabel.font = UIFont.font(sized: 14, weight: .light, with: .title3)
        emptyStateOrLabel.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        importFromRemindersButton.titleLabel?.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        importFromRemindersButton.titleLabel?.numberOfLines = 1
        
        emptyStateTitleLabel.text = viewModel.emptyStateTitleText
        emptyStateSubtitleLabel.text = viewModel.emptyStateSubtitleText
        emptyStateOrLabel.text = viewModel.emptyStateOrText
        importFromRemindersButton.setTitle(viewModel.importFromRemindersText,
                                           for: .normal)
    }
    
    fileprivate func configureBigTitle() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bigTitle.text = viewModel.bigTitleText
        maskLabel.text = viewModel.bigTitleText
        
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        maskLabel.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        
        titleGradient.colors = bigTitleColors
        CATransaction.commit()
    }
    
    var bigTitleColors: [CGColor] {
        return viewModel.selectedTags.isEmpty
            ? [UIColor.black.cgColor, UIColor.black.cgColor]
            : viewModel.selectedTags.first!.colors
    }
    
    @IBAction func didTapBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel.deselectBigTitle(tag: tag)
            
            Answers.logCustomEvent(withName: "unselected tag on screen title")
        }
    }
    
    @IBAction func didLongpressBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            tagCollectionViewController.presentActionSheet(for: tag)
            Answers.logCustomEvent(withName: "longpressed tag")
        }
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
