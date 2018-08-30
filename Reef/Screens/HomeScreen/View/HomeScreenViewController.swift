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
import UserNotifications

class HomeScreenViewController: UIViewController {
    
    var viewModel: HomeScreenViewModel!
    
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var bigTitle: UILabel!
    
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate var tagCollectionViewController: TagCollectionViewController?

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
    
    func setupTaskList(viewModel: TaskListViewModel,
                       viewController: TaskListViewController) {
        
        guard taskListViewController == nil else { return }
        taskListViewController = viewController
        
        subscribe(to: viewModel)
        
        addChildViewController(viewController)
        taskListContainerView.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.rightAnchor.constraint(equalTo: taskListContainerView.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: taskListContainerView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: taskListContainerView.leftAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: taskListContainerView.bottomAnchor)
        ])
    }
    
    func setupTagCollection(viewModel: TagCollectionViewModel, viewController: TagCollectionViewController) {
        guard tagCollectionViewController == nil else { return }
        
        tagCollectionViewController = viewController
        
        addChildViewController(viewController)
        tagContainerView.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.rightAnchor.constraint(equalTo: tagContainerView.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: tagContainerView.leftAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor)
        ])
    }
    
    fileprivate func subscribe(to taskListViewModel: TaskListViewModel) {
        taskListViewModel.shouldAddTask
            .subscribe(onNext: { shouldAddTask in
            	if shouldAddTask {
                	let selectedTags = self.viewModel.tagCollectionViewModel.selectedTags
                    // TODO: Refactor this to fit into architecture
                	self.viewModel.delegate?.homeScreenViewModel(self.viewModel,
                                                             willAddTaskWithSelectedTags: selectedTags)
            	}
        	})
            .disposed(by: disposeBag)
        
        taskListViewModel.shouldEditTask
            .subscribe(onNext: { task in
                // TODO: Refactor this to fit into architecture
            	self.viewModel.delegate?.homeScreenViewModel(self.viewModel, willEdit: task)
        	})
            .disposed(by: disposeBag)
        
        taskListViewModel.tasksObservable
            .subscribe(onNext: { tasks in
            	DispatchQueue.main.async {
                    self.showEmptyState( tasks.flatMap { $0 }.isEmpty )
            	}
        	})
            .disposed(by: disposeBag)
    }
    
    fileprivate func observeClickedAddTag() {
        // TODO Refactor this to fit into the architecture
        tagCollectionViewController?.addTagEvent?
            .subscribe { _ in
            	self.viewModel.delegate?.homeScreenViewModelWillAddTag(self.viewModel)
        	}
            .disposed(by: disposeBag)
    }
    
    fileprivate func observeSelectedTags() {
        viewModel.tagCollectionViewModel.selectedTagsObservable
            .subscribe(onNext: { selectedTags in
                self.viewModel.updateSelectedTagsIfNeeded(selectedTags)
                self.configureBigTitle()
                
                let relatedTags = self.viewModel.tagCollectionViewModel.filteredTags.filter {
                    !selectedTags.contains($0)
                }
                
                self.viewModel.taskListViewModel.filterTasks(with: selectedTags, relatedTags: relatedTags)
                
                if let activity = self.userActivity {
                    self.updateUserActivityState(activity)
                }
                
                if !selectedTags.isEmpty {
                    Answers.logCustomEvent(withName: "filtered with tag",
                                           customAttributes: ["numberOfFilteredTags" : selectedTags.count])
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Empty State
    @IBOutlet weak var emptyStateImage: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateSubtitleLabel: UILabel!
    @IBOutlet weak var emptyStateOrLabel: UILabel!
    @IBOutlet weak var importFromRemindersButton: UIButton!
    
    fileprivate func showEmptyState(_ shouldShowEmptyState: Bool) {
        emptyStateSubtitleLabel.isHidden = !shouldShowEmptyState
        emptyStateTitleLabel.isHidden = !shouldShowEmptyState
        emptyStateImage.isHidden = !shouldShowEmptyState
        
        // TODO: Refactor this to fit into architecture
        if shouldShowEmptyState,
           viewModel.delegate?.homeScreenViewModelShouldShowImportFromRemindersOption(viewModel) ?? false {
            emptyStateOrLabel.isHidden = false
            importFromRemindersButton.isHidden = false
        } else {
            emptyStateOrLabel.isHidden = true
            importFromRemindersButton.isHidden = true
        }
    }
    
    @IBAction func didClickImportFromRemindersButton(_ sender: Any) {
        // TODO: Refactor this to fit into architecture
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
            // TODO Refactor this to fit into architecture
            tagCollectionViewController?.presentActionSheet(for: tag)
            Answers.logCustomEvent(withName: "longpressed big title")
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
