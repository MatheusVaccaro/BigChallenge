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
        title = viewModel.bigTitleText
        
        whiteBackgroundView.layer.cornerRadius = 6.3
        whiteBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
        configureEmptyState()
        if isPresentingMoreOptions {
            animateMoreOptionsShowing()
        } else {
            animateAddTaskShowing()
        }
    }
    
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var addTaskViewTopConstraint: NSLayoutConstraint!
    private var taskCreationFrameViewController: TaskCreationFrameViewController!
    
    func setupAddTask(viewController: TaskCreationFrameViewController) {
        
        taskCreationFrameViewController = viewController
        
        addChild(viewController)
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
        
        addChild(viewController)
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
        
        addChild(viewController)
        tagContainerView.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.rightAnchor.constraint(equalTo: tagContainerView.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: tagContainerView.leftAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor)
        ])
    }
    
    fileprivate func subscribe(to taskListViewModel: TaskListViewModel) {
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
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        viewModel.updateUserActivity(activity)
    }
    
    fileprivate var isPresentingMoreOptions: Bool = false
    fileprivate var isPresentingAddTask: Bool = false
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideAddTask))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private func applyBlur() {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            blurView.frame = view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if !blurView.isDescendant(of: view) {            
                view.insertSubview(blurView, belowSubview: newTaskView)
            }
        } else {
            view.backgroundColor = .black
        }
    }
    
    private func removeBlur() {
        blurView.removeFromSuperview()
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

extension HomeScreenViewController {
    // action from homescreen
    @objc func hideAddTask() {
        prepareToHideAddTask()
        viewModel.endAddTask()
    }
    
    @objc func presentAddTask() {
        prepareToPresentAddTask()
        viewModel.startAddTask()
    }
    
    
    //actions from other screens
    func prepareToPresentAddTask() {
        guard !isPresentingAddTask else { return }
        isPresentingAddTask = true
        isPresentingMoreOptions = false
        tagCollectionViewController!.viewModel.filtering = false
        animateAddTaskShowing()
        applyBlur()
    }
    
    func prepareToHideAddTask() {
        guard isPresentingAddTask || isPresentingMoreOptions else { return }
        isPresentingAddTask = false
        isPresentingMoreOptions = false
        tagCollectionViewController!.viewModel.filtering = true
        animateAddTaskHidden()
        removeBlur()
    }
    
    func prepareToPresentMoreOptions() {
        guard !isPresentingMoreOptions else { return }
        isPresentingAddTask = false
        isPresentingMoreOptions = true
        animateMoreOptionsShowing()
        applyBlur()
    }
    
    func prepareToHideMoreOptions() {
        guard isPresentingMoreOptions else { return }
        isPresentingAddTask = true
        isPresentingMoreOptions = false
        animateAddTaskShowing()
    }
    
    func didPanAddTask() {
        //code
    }
    
    fileprivate func animateAddTaskHidden() {
        UIView.animate(withDuration: 0.25) {
            self.addTaskViewTopConstraint.constant =
                (self.taskCreationFrameViewController.hiddenHeight - 20) - self.newTaskView.bounds.height
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func animateAddTaskShowing() {
        UIView.animate(withDuration: 0.25) {
            self.addTaskViewTopConstraint.constant =
                self.taskCreationFrameViewController.hiddenHeight - self.newTaskView.bounds.height
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func animateMoreOptionsShowing() {
        UIView.animate(withDuration: 0.25) {
            self.addTaskViewTopConstraint.constant =
                self.taskCreationFrameViewController.contentSize - self.newTaskView.bounds.height
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Accessibility
extension HomeScreenViewController {
    override func accessibilityPerformMagicTap() -> Bool {
        if !isPresentingAddTask {
            presentAddTask()
            return true
        } else {
            return false
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        if isPresentingAddTask {
            hideAddTask()
            return true
        } else {
            return false
        }
    }
}
