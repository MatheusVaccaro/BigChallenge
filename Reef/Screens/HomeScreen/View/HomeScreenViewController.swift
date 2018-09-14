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
    @IBOutlet weak var whiteBackgroundView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigTitle.textColor = UIColor.black
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        whiteBackgroundView.layer.cornerRadius = 6.3
        whiteBackgroundView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner ]
        whiteBackgroundView.tintColor = UIColor.white
        
        whiteBackgroundView.layer.shadowRadius = 6.3
        whiteBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)
        whiteBackgroundView.layer.masksToBounds = false
        whiteBackgroundView.layer.shadowColor = CGColor.shadowColor
        whiteBackgroundView.layer.shadowOpacity = 0.2
        
        view.layer.addSublayer(gradientLayer)
        
        configureEmptyState()
        observeSelectedTags()
        observeClickedAddTag()
        userActivity = viewModel.userActivity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        configureEmptyState()
        if isPresentingAddTask {
            setupAddTaskShowing()
        } else {
            setupAddTaskHidden()
        }
    }
    
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var addTaskHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskViewTopConstraint: NSLayoutConstraint!
    private var taskCreationFrameViewController: TaskCreationFrameViewController!

    fileprivate func setupAddTaskHidden() {
        addTaskViewTopConstraint.constant =
            taskCreationFrameViewController.hiddenHeight - newTaskView.bounds.height
    }
    
    fileprivate func setupAddTaskShowing() {
        addTaskViewTopConstraint.constant =
            taskCreationFrameViewController.contentSize - newTaskView.bounds.height
    }
    
    func setupAddTask(viewController: TaskCreationFrameViewController) {
        
        taskCreationFrameViewController = viewController
        
        addChildViewController(viewController)
        newTaskView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.rightAnchor.constraint(equalTo: newTaskView.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: newTaskView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: newTaskView.leftAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: newTaskView.bottomAnchor)
            ])
    }
    
    func setupTaskList(viewModel: TaskListViewModel, viewController: TaskListViewController) {
        
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
                	self.viewModel.delegate?
                        .homeScreenViewModel(self.viewModel, willAddTaskWithSelectedTags: selectedTags)
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
        
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        
        CATransaction.commit()
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        viewModel.updateUserActivity(activity)
    }
    
    fileprivate var isPresentingAddTask: Bool = false
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isPresentingAddTask else { return }
        isPresentingAddTask = false
        setupAddTaskHidden()
    }
}

extension HomeScreenViewController {
    func prepareToPresentAddTask() {
        //TODO:
    }
    
    func didPanAddTask() {
        //code
    }
    
    func prepareToPresentMoreOptions() {
        guard !isPresentingAddTask else { return }
        isPresentingAddTask = true
        viewModel.delegate?.homeScreenViewModel(viewModel, willAddTaskWithSelectedTags: viewModel.selectedTags)
        setupAddTaskShowing()
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

extension UIView {
    func applyBlur(style: UIBlurEffectStyle) {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            addSubview(blurEffectView)
        } else {
            backgroundColor = .black
        }
    }
}
