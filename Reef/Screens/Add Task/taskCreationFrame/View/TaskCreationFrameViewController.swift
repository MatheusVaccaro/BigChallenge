//
//  TaskCreationFrameViewController.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFrameViewController: UIViewController {
    
    @IBOutlet weak var taskTitleAndDetailSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var taskDetailsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var taskContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var taskDetailView: UIView!
    @IBOutlet weak var taskTitleView: UIView!
    @IBOutlet weak var taskContainerView: UIView!
    @IBOutlet weak var taskTitleViewHeightConstraint: NSLayoutConstraint!
    
    var taskTitleViewHeight: CGFloat {
        return taskTitleView.bounds.height
    }
    
    var taskDetailViewHeight: CGFloat {
        return taskDetailsTableViewHeight.constant
    }
    
    var taskTitleAndDetailSeparatorHeight: CGFloat {
        return taskTitleAndDetailSeparatorConstraint.constant
    }
    
    var taskContainerViewHeight: CGFloat {
        return taskDetailViewHeight + taskTitleAndDetailSeparatorHeight + taskTitleViewHeight
    }
    
    var tagCollectionViewController: TagCollectionViewController!
    var taskDetailViewController: AddDetailsViewController!
    var newTaskViewController: NewTaskViewController!
    
    var viewModel: TaskCreationViewModel!
    
    private(set) lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: ReefColors.blurStyle)
        
        let blur = UIVisualEffectView(effect: blurEffect)
        blur.frame = view.bounds
        
        return blur
    }()
    
    // MARK: - Animations Properties
    private let duration: TimeInterval = 0.25
    private var animationDistance: CGFloat!
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted: CGFloat = 0
    private let minimunProgressToCompleteAnimation: CGFloat = 0.2
    
    private var state: State = .collapsed {
        didSet {
            print("Current State: \(state)")
            if state == .expanded {
                newTaskViewController.prepareViewToShowDetails(true)
            } else {
                newTaskViewController.prepareViewToShowDetails(false)
            }
        }
    }
    
    func present(_ taskDetailViewController: AddDetailsViewController) {
        self.taskDetailViewController = taskDetailViewController
        addChild(taskDetailViewController)
        taskDetailView.addSubview(taskDetailViewController.view)
        taskDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        taskDetailViewController.view.layer.cornerRadius = 6.3
        taskDetailViewController.view.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            taskDetailViewController.view.rightAnchor.constraint(equalTo: taskDetailView.rightAnchor),
            taskDetailViewController.view.topAnchor.constraint(equalTo: taskDetailView.topAnchor),
            taskDetailViewController.view.leftAnchor.constraint(equalTo: taskDetailView.leftAnchor),
            taskDetailViewController.view.bottomAnchor.constraint(equalTo: taskDetailView.bottomAnchor)
            ])
        taskDetailViewController.didMove(toParent: self)
        
        let taskDetailTableView = taskDetailViewController.tableView as? ContentSizeObservableTableView
        taskDetailTableView?.contentSizeDelegate = self
    }
    
    func present(_ taskTitleViewController: NewTaskViewController) {
        self.newTaskViewController = taskTitleViewController
        addChild(taskTitleViewController)
        taskTitleView.addSubview(taskTitleViewController.view)
        newTaskViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskViewController.view.rightAnchor.constraint(equalTo: taskTitleView.rightAnchor),
            newTaskViewController.view.topAnchor.constraint(equalTo: taskTitleView.topAnchor),
            newTaskViewController.view.leftAnchor.constraint(equalTo: taskTitleView.leftAnchor),
            newTaskViewController.view.bottomAnchor.constraint(equalTo: taskTitleView.bottomAnchor)
            ])
        newTaskViewController.didMove(toParent: self)
        
        taskTitleViewController.taskTitleTextView.contentSizeDelegate = self
    }
    
    func present(_ tagCollectionViewController: TagCollectionViewController) {
        self.tagCollectionViewController = tagCollectionViewController
        addChild(tagCollectionViewController)
        tagCollectionView.addSubview(tagCollectionViewController.view)
        tagCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagCollectionViewController.view.rightAnchor.constraint(equalTo: tagCollectionView.rightAnchor),
            tagCollectionViewController.view.topAnchor.constraint(equalTo: tagCollectionView.topAnchor),
            tagCollectionViewController.view.leftAnchor.constraint(equalTo: tagCollectionView.leftAnchor),
            tagCollectionViewController.view.bottomAnchor.constraint(equalTo: tagCollectionView.bottomAnchor)
            ])
        tagCollectionViewController.didMove(toParent: self)
    }
    
    private func applyBlur() {
        //only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled {
            blurView.tintColor = ReefColors.cellIcons
        }
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if !blurView.isDescendant(of: view) {
            view.insertSubview(blurView, at: 0)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        blurView.addGestureRecognizer(gesture)
    }
    
    private func removeBlur() {
        blurView.removeFromSuperview()
    }
    
    @objc func dismissViewController() {
        viewModel.delegate?.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.bigTitleText
        
        configureShadows(in: whiteBackgroundView)
        configureShadows(in: taskDetailView)
        configureShadows(in: taskTitleView)
        
        whiteBackgroundView.backgroundColor = ReefColors.tagsBackground
        
        applyBlur()
        
        viewModel.delegate?.viewDidLoad()
        taskDetailViewController.accessibilityElementsHidden = true
        
        addGestureRecognizersForAnimations()
    }
    
    private var didSetInitialContainerViewPosition: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationDistance = taskContainerViewHeight
        
        if !didSetInitialContainerViewPosition {
            taskContainerViewTopConstraint.constant = -taskDetailViewHeight
            didSetInitialContainerViewPosition = true
        }
    }
    
    private func configureShadows(in view: UIView) {
        view.layer.cornerRadius = 6.3
        view.tintColor = UIColor.white
        
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.masksToBounds = false
        view.layer.shadowColor = ReefColors.shadow
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
    }
}

extension TaskCreationFrameViewController: ContentSizeObservableTableViewDelegate {
    func tableView(_ tableView: ContentSizeObservableTableView, didUpdateContentSize contentSize: CGSize) {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationControllerHeight = navigationController!.navigationBar.frame.height
        let offset: CGFloat = 40.0

        let interactableArea = view.frame.height - statusBarHeight - navigationControllerHeight - offset

        let taskContainerExpectedSize = taskTitleAndDetailSeparatorHeight + taskTitleViewHeight + contentSize.height
        if taskContainerExpectedSize > interactableArea {
            tableView.isScrollEnabled = true
            let maxTaskDetailsTableViewHeight =
                interactableArea - taskTitleAndDetailSeparatorHeight - taskTitleViewHeight
            taskDetailsTableViewHeight.constant = maxTaskDetailsTableViewHeight
        } else {
            tableView.isScrollEnabled = false
            taskDetailsTableViewHeight.constant = contentSize.height
        }

        // Adjusts position of container view when its collapsed
        // This line is needed in case the user taps a tag when the container is collapsed
        if state == .collapsed {
            taskContainerViewTopConstraint.constant = -taskDetailViewHeight
        }
    }
}

extension TaskCreationFrameViewController: UITextViewContentSizeDelegate {
    func textView(_ textView: UITextView, didChangeContentSize contentSize: CGSize) {
        let maxTaskTitleHeight: CGFloat = 75
        let taskTitleTopAndBottomConstraints: CGFloat = 16 + 16
        let taskTitleExpectedHeight = contentSize.height + taskTitleTopAndBottomConstraints
        
        if taskTitleExpectedHeight > maxTaskTitleHeight {
            textView.isScrollEnabled = true
            taskTitleViewHeightConstraint.constant = maxTaskTitleHeight
        } else {
            textView.isScrollEnabled = false
            taskTitleViewHeightConstraint.constant = taskTitleExpectedHeight
        }
    }
}

extension TaskCreationFrameViewController {
    override func accessibilityPerformEscape() -> Bool {
        viewModel.delegate?.dismiss()
        return true
    }
}

extension TaskCreationFrameViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "taskCreationFrame"
    }
    
    static var storyboardIdentifier: String {
        return "TaskCreation"
    }
}

extension TaskCreationFrameViewController {
    // MARK: Animations
    func addGestureRecognizersForAnimations() {
//        taskContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
//                                                                      action: #selector(handleTapGesture(_:))))
        
        taskContainerView.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                                      action: #selector(handlePanGesture(_:))))
    }
    
//    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
//        newTaskViewController.taskTitleTextView.resignFirstResponder()
//        animateOrReverseRunningTransition(state: !state, duration: duration)
//    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        newTaskViewController.taskTitleTextView.resignFirstResponder()
        
        let translation = recognizer.translation(in: taskContainerView)
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
        addTaskContainerAnimation(for: state, with: duration)
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
        let cancel: Bool = fractionComplete < minimunProgressToCompleteAnimation
        
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
    
    private func addTaskContainerAnimation(for state: State, with duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [unowned self] in
            switch state {
            case .collapsed:
                self.taskContainerViewTopConstraint.constant = -self.taskDetailViewHeight
            case .expanded:
                self.taskContainerViewTopConstraint.constant = 0
                
            }
            self.view.layoutIfNeeded()
        }
        animator.addCompletion { [unowned self] status in
            switch status {
            case .end:
                self.state = state
            default:
                break
            }
            self.runningAnimators.removeAll()
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
    
    private func animateDetailsBump(completionHandler: @escaping () -> Void) {
        let duration = 0.3
        let options: UIView.KeyframeAnimationOptions = [.calculationModeCubic]
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0.0,
                                options: options,
                                animations: { [unowned self] in
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { [unowned self] in
                                        self.taskContainerView.frame.origin.y += self.taskTitleAndDetailSeparatorHeight
                                    })

                                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [unowned self] in
                                        self.taskContainerView.frame.origin.y -= self.taskTitleAndDetailSeparatorHeight
                                    })
            }, completion: { _ in
                completionHandler()
        })
    }
}

extension TaskCreationFrameViewController: TaskCreationUIDelegate {
    func taskCreationViewModelDidChangeTaskInfo(_ taskCreationViewModel: TaskCreationViewModel) {
        if state == .collapsed {
            animateDetailsBump { [unowned self] in
                self.taskDetailViewController.tableView.reloadData()
            }
        } else {
            taskDetailViewController.tableView.reloadData()
        }
    }
    
    func presentDetails() {
        guard state == .collapsed else { return }
        animateOrReverseRunningTransition(state: .expanded, duration: duration)
        taskDetailViewController.accessibilityElementsHidden = false
    }
    
    func hideDetails() {
        guard state == .expanded else { return }
        animateOrReverseRunningTransition(state: .collapsed, duration: duration)
        taskDetailViewController.accessibilityElementsHidden = true
    }

}

private enum State {
    case collapsed
    case expanded
}

private prefix func ! (_ state: State) -> State {
    return state == State.expanded ? .collapsed : .expanded
}
