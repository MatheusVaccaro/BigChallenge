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
import UserNotifications

protocol HomeScreenViewControllerDelegate: class {
    func viewDidLoad()
}

class HomeScreenViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: HomeScreenViewModel!
    
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate var tagCollectionViewController: TagCollectionViewController?
    
    weak var delegate: HomeScreenViewControllerDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var newTaskLabel: UILabel!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullDownStackView: UIStackView!
    @IBOutlet weak var pullDownArrowImage: UIImageView!
    
    // MARK: - Animation IBOutlets
    @IBOutlet weak var pullDownView: UIView!
    @IBOutlet weak var pullDownViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.bigTitleText
        
        view.backgroundColor = ReefColors.background
        
        configureWhiteBackgroundView()
        configureEmptyState()
        newTaskLabel.text = Strings.Task.CreationScreen.taskTitlePlaceholder
        userActivity = viewModel.userActivity
        
        configurePullDownView()
        delegate?.viewDidLoad()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        newTaskLabel.font = UIFont.font(sized: 13, weight: .medium, with: .body)
        emptyStateTitleLabel.font = UIFont.font(sized: 18, weight: .bold, with: .title2)
        emptyStateSubtitleLabel.font = UIFont.font(sized: 14, weight: .light, with: .title3)
        emptyStateOrLabel.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        importFromRemindersButton.titleLabel?.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        
        taskListContainerTopConstraint.constant = pullDownStackView.frame.height + 12 + 16
    }
    
    func setupTaskList(viewModel: TaskListViewModel, viewController: TaskListViewController) {
        
        guard taskListViewController == nil else { return }
        taskListViewController = viewController
        
        viewModel.delegate = self
        showEmptyState(viewModel.taskListData.isEmpty)
        
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
    
    fileprivate func configureWhiteBackgroundView() {
        whiteBackgroundView.layer.cornerRadius = 6.3
        whiteBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        whiteBackgroundView.backgroundColor = ReefColors.tagsBackground
        
        whiteBackgroundView.layer.shadowRadius = 6.3
        whiteBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)
        whiteBackgroundView.layer.masksToBounds = false
        whiteBackgroundView.layer.shadowColor = ReefColors.shadow
        whiteBackgroundView.layer.shadowOpacity = 1
        whiteBackgroundView.layer.shadowRadius = 10
    }
    
    fileprivate func configureEmptyState() {
        importFromRemindersButton.titleLabel?.numberOfLines = 1
        
        emptyStateTitleLabel.text = viewModel.emptyStateTitleText
        emptyStateSubtitleLabel.text = viewModel.emptyStateSubtitleText
        emptyStateOrLabel.text = viewModel.emptyStateOrText
        importFromRemindersButton.setTitle(viewModel.importFromRemindersText,
                                           for: .normal)
        
        emptyStateImage.image = UIImage(named: "emptyState")?.withRenderingMode(.alwaysTemplate)
        
        emptyStateImage.tintColor = ReefColors.largeTitle
        emptyStateTitleLabel.textColor = ReefColors.largeTitle
        emptyStateSubtitleLabel.textColor = ReefColors.largeTitle
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        viewModel.updateUserActivity(activity)
    }
    
    private func configurePullDownView() {
        pullDownView.backgroundColor = .white
        pullDownView.layer.cornerRadius = 6.3
        pullDownView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner ]
        pullDownView.backgroundColor = ReefColors.tagsBackground
        pullDownArrowImage.tintColor = ReefColors.placeholder
        newTaskLabel.textColor = ReefColors.placeholder
        pullDownArrowImage.image = UIImage(named: "pullDownArrow")?.withRenderingMode(.alwaysTemplate)
        
        pullDownView.layer.shadowRadius = 6.3
        pullDownView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pullDownView.layer.masksToBounds = false
        pullDownView.layer.shadowColor = ReefColors.shadow
        pullDownView.layer.shadowOpacity = 1
        pullDownView.layer.shadowRadius = 10
        
        pullDownView.accessibilityValue = Strings.Task.CreationScreen.taskTitlePlaceholder
        pullDownView.accessibilityTraits = UIAccessibilityTraits.button
        pullDownView.isAccessibilityElement = true
        
        pullDownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startAddTask)))
    }
    
    @objc private func startAddTask() {
        viewModel.startAddTask()
    }
}

extension HomeScreenViewController: TaskListDelegate {
    func didBecomeEmpty(_ bool: Bool) {
        showEmptyState(bool)
    }
    
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, shouldEdit task: Task) {
        viewModel.delegate?.homeScreenViewModel(viewModel, willEdit: task)
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
    
    override var accessibilityCustomRotors: [UIAccessibilityCustomRotor]? {
        get {
            return nil //TODO
        }
        set {
            
        }
    }
}
