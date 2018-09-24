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
    
    // MARK: - Properties
    fileprivate var isPresentingMoreOptions: Bool = false
    fileprivate var isPresentingAddTask: Bool = false
    
    var viewModel: HomeScreenViewModel!
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate var tagCollectionViewController: TagCollectionViewController?
    private var taskCreationFrameViewController: TaskCreationFrameViewController!
    
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
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var addTaskViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Animations Properties
    private let duration: TimeInterval = 0.5
    private let animationDistance: CGFloat = 38
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted: CGFloat = 0
    
    private var state: State = .collapsed {
        didSet {
            print("Current State: \(state)")
        }
    }
    
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
        observeClickedAddTag()
        userActivity = viewModel.userActivity
        
        configurePullDownView()
        addGestureRecognizersForAnimations()
        
        newTaskView.alpha = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureEmptyState()
        if isPresentingMoreOptions {
//            animateMoreOptionsShowing()
        } else {
//            animateAddTaskShowing()
        }
    }
    
    func dismissAddTag() {
        addTagView.removeFromSuperview()
    }
    
    //MARK: Add task
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
    
    // MARK: Add tag
    
    @IBOutlet weak var addTagView: UIView!
    private var tagCreationFrameViewController: TagCreationFrameViewController!
    func setupAddTag(viewController: TagCreationFrameViewController) {
        tagCreationFrameViewController = viewController
        
        addTagView.backgroundColor = UIColor.clear
        self.view.addSubview(addTagView!)
        
        NSLayoutConstraint.activate([
            addTagView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            addTagView.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            addTagView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            addTagView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        addChild(viewController)
        addTagView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.rightAnchor.constraint(equalTo: addTagView.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: addTagView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: addTagView.leftAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: addTagView.bottomAnchor)
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
}

extension HomeScreenViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "HomeScreenViewController"
    }
    
    static var storyboardIdentifier: String {
        return "HomeScreen"
    }
}

//extension HomeScreenViewController {
//    // action from homescreen
//    @objc func hideAddTask() {
//        prepareToHideAddTask()
//        viewModel.endAddTask()
//    }
//
//    @objc func presentAddTask() {
////        prepareToPresentAddTask()
//        viewModel.startAddTask()
//    }
//
//
//    //actions from other screens
//    func prepareToPresentAddTask() {
//        guard !isPresentingAddTask else { return }
//        isPresentingAddTask = true
//        isPresentingMoreOptions = false
//        tagCollectionViewController!.viewModel.filtering = false
//        animateAddTaskShowing()
//        applyBlur()
//    }
//
//    func prepareToHideAddTask() {
//        guard isPresentingAddTask || isPresentingMoreOptions else { return }
//        isPresentingAddTask = false
//        isPresentingMoreOptions = false
//        tagCollectionViewController!.viewModel.filtering = true
//        animateAddTaskHidden()
//        removeBlur()
//    }
//
//    func prepareToPresentMoreOptions() {
//        guard !isPresentingMoreOptions else { return }
//        isPresentingAddTask = false
//        isPresentingMoreOptions = true
//        animateMoreOptionsShowing()
//        applyBlur()
//    }
//
//    func prepareToHideMoreOptions() {
//        guard isPresentingMoreOptions else { return }
//        isPresentingAddTask = true
//        isPresentingMoreOptions = false
//        animateAddTaskShowing()
//    }
//
//    func didPanAddTask() {
//        //code
//    }
//
//    fileprivate func animateAddTaskHidden() {
//        UIView.animate(withDuration: 0.25) {
//            self.addTaskViewTopConstraint.constant =
//                (self.taskCreationFrameViewController.hiddenHeight - 20) - self.newTaskView.bounds.height
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    fileprivate func animateAddTaskShowing() {
////        UIView.animate(withDuration: 0.25) {
////            self.addTaskViewTopConstraint.constant =
////                self.taskCreationFrameViewController.hiddenHeight - self.newTaskView.bounds.height
////            self.view.layoutIfNeeded()
////        }
//    }
//
//    fileprivate func animateMoreOptionsShowing() {
//        UIView.animate(withDuration: 0.25) {
//            self.addTaskViewTopConstraint.constant =
//                self.taskCreationFrameViewController.contentSize - self.newTaskView.bounds.height
//            self.view.layoutIfNeeded()
//        }
//    }
//}

// MARK: - Accessibility
extension HomeScreenViewController {
    override func accessibilityPerformMagicTap() -> Bool {
        if !isPresentingAddTask {
//            presentAddTask()
            return true
        } else {
            return false
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        if isPresentingAddTask {
//            hideAddTask()
            return true
        } else {
            return false
        }
    }
}

// MARK: - Animations
// WWDC Keynote Reference: https://developer.apple.com/videos/play/wwdc2017/230/
// Github Reference: https://github.com/kane-liu/AdvancedAnimations

private enum State {
    case collapsed
    case expanded
}

private prefix func ! (_ state: State) -> State {
    return state == State.expanded ? .collapsed : .expanded
}

extension HomeScreenViewController {
    
    // MARK: View Configuration
    private func configurePullDownView() {
        pullDownView.backgroundColor = .white
        pullDownView.layer.cornerRadius = 6.3
        pullDownView.tintColor = .white
        
        pullDownView.layer.shadowRadius = 6.3
        pullDownView.layer.shadowOffset = CGSize(width: 0, height: 10)
        pullDownView.layer.masksToBounds = false
        pullDownView.layer.shadowColor = .shadowColor
        pullDownView.layer.shadowOpacity = 0.2
    }
    
    // MARK: Animations
    func addGestureRecognizersForAnimations() {
//        pullDownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
//        pullDownView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        
        pullDownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startAddTask)))
    }
    
    @objc private func startAddTask() {
        viewModel.startAddTask()
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        animateOrReverseRunningTransition(state: !state, duration: duration)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: pullDownView)
        let fraction = fractionComplete(state: !state, translation: translation)
        
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: !state, duration: duration)
        case .changed:
            updateInteractiveTransition(fractionComplete: fraction)
        case .ended:
            continueInteractiveTransition(fractionComplete: fraction)
        default:
            break
        }
    }
    
    // Perform all animations with animators if not already running
    private func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        addPullDownAnimation(for: state, with: duration)
        addPullDownFadeOutAnimation(for: state, with: duration)
//        addNewTaskViewFadeInAnimation(for: state, with: duration)
    }
    
    // Starts transition if necessary or reverses it on tap
    private func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
            startAnimators()
        } else {
            reverseRunningAnimators()
        }
    }
    
    // Starts transition if necessary and pauses on pan .began
    private func startInteractiveTransition(state: State, duration: TimeInterval) {
        animateTransitionIfNeeded(state: state, duration: duration)
        pauseAnimators()
        progressWhenInterrupted = runningAnimators.first?.fractionComplete ?? 0
    }
    
    // Scrubs transition on pan .changed
    private func updateInteractiveTransition(fractionComplete: CGFloat) {
        runningAnimators.forEach {
            $0.fractionComplete = fractionComplete
        }
    }
    
    // Continues or reverse transition on pan .ended
    private func continueInteractiveTransition(fractionComplete: CGFloat) {
        let cancel: Bool = fractionComplete < 0.35
        
        if cancel {
            runningAnimators.forEach {
                $0.isReversed = !$0.isReversed
                $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
            return
        }
        
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        runningAnimators.forEach {
            $0.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        }
    }
    
    private func addPullDownAnimation(for state: State, with duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
            switch state {
            case .collapsed:
                self?.pullDownViewTopConstraint.constant = -22
            case .expanded:
                self?.pullDownViewTopConstraint.constant = 16
                
            }
            self?.view.layoutIfNeeded()
        }
        animator.addCompletion { [weak self] status in
            switch status {
            case .end:
                self?.state = state
            default:
                break
            }
            self?.runningAnimators.removeAll()
        }
        runningAnimators.append(animator)
    }
    
    private func addPullDownFadeOutAnimation(for state: State, with duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            UIView.animateKeyframes(withDuration: 0, delay: 0, options: [], animations: {
                switch state {
                case .collapsed:
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration / 2) { [weak self] in
                        self?.pullDownView.alpha = 1
                    }
                case .expanded:
                    UIView.addKeyframe(withRelativeStartTime: duration / 2, relativeDuration: duration / 2) { [weak self] in
                        self?.pullDownView.alpha = 0.1
                    }
                }
            }, completion: nil)
        }
        runningAnimators.append(animator)
    }
    
    private func addNewTaskViewFadeInAnimation(for state: State, with duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            UIView.animateKeyframes(withDuration: 0, delay: 0, options: [], animations: {
                switch state {
                case .collapsed:
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration / 2) { [weak self] in
                        self?.newTaskView.alpha = 0
                    }
                case .expanded:
                    UIView.addKeyframe(withRelativeStartTime: duration / 2, relativeDuration: duration / 2) { [weak self] in
                        self?.newTaskView.alpha = 1
                    }
                }
            }, completion: nil)
        }
        runningAnimators.append(animator)
    }
    
    private func startAnimators() {
        // Added setNeedsLayout to fix a bug where animations would not play if they were reversed
        view.setNeedsLayout()
        for animator in runningAnimators {
            animator.startAnimation()
        }
    }
    
    private func reverseRunningAnimators() {
        for animator in runningAnimators {
            animator.isReversed = !animator.isReversed
        }
    }
    
    private func pauseAnimators() {
        // Added setNeedsLayout to fix a bug where animations would not play if they were reversed
        view.setNeedsLayout()
        for animator in runningAnimators {
            animator.pauseAnimation()
        }
    }
    
    private func fractionComplete(state: State, translation: CGPoint) -> CGFloat {
        let translationY: CGFloat
        if state == .expanded {
            translationY = translation.y
        } else {
            translationY = -translation.y
        }
        
        let fractionComplete = translationY / animationDistance + progressWhenInterrupted
        return fractionComplete
    }
}
