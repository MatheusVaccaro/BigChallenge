//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Crashlytics
import ReefKit
import RxSwift
import UserNotifications

class HomeScreenViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: HomeScreenViewModel!
    
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
    
    // MARK: - IBOutlets
    @IBOutlet weak var newTaskLabel: UILabel!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var addTaskViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Animation IBOutlets
    @IBOutlet weak var pullDownView: UIView!
    @IBOutlet weak var pullDownViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
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
        newTaskLabel.text = Strings.Task.CreationScreen.taskTitlePlaceholder
        userActivity = viewModel.userActivity
        
        configurePullDownView()
        
        newTaskView.alpha = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        newTaskLabel.font = UIFont.font(sized: 13,
                                        weight: .medium,
                                        with: .body)
        configureEmptyState()
    }
    
    func setupTaskList(viewModel: TaskListViewModel, viewController: TaskListViewController) {
        
        guard taskListViewController == nil else { return }
        taskListViewController = viewController
        
        viewModel.delegate = self
        
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
    
    fileprivate func observeSelectedTags() { //Move to homeScreen Coordinator (preferably on delegate)
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
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideAddTask))
//        view.addGestureRecognizer(tapGesture)
        
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
    
    private func configurePullDownView() {
        pullDownView.backgroundColor = .white
        pullDownView.layer.cornerRadius = 6.3
        pullDownView.tintColor = .white
        
        pullDownView.layer.shadowRadius = 6.3
        pullDownView.layer.shadowOffset = CGSize(width: 0, height: 10)
        pullDownView.layer.masksToBounds = false
        pullDownView.layer.shadowColor = .shadowColor
        pullDownView.layer.shadowOpacity = 0.2
        
        pullDownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startAddTask)))
    }
    
    @objc private func startAddTask() {
        viewModel.startAddTask()
    }
}

extension HomeScreenViewController: TaskListDelegate {
    func didBecomeEmpty(_ bool: Bool) {
        self.showEmptyState(bool)
    }
    
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, shouldEdit task: Task) {
        self.viewModel.delegate?.homeScreenViewModel(viewModel, willEdit: task)
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

// MARK: - Accessibility
extension HomeScreenViewController {
    override func accessibilityPerformMagicTap() -> Bool {
        viewModel.startAddTask()
        return true
    }
}
