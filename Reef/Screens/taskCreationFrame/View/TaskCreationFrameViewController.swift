//
//  TaskCreationFrameViewController.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFrameViewController: UIViewController {
    
    @IBOutlet weak var taskContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var taskDetailView: UIView!
    @IBOutlet weak var taskTitleView: UIView!
    @IBOutlet weak var taskContainerView: UIView!
    
    var hiddenHeight: CGFloat {
        return taskTitleView.bounds.height
    }
    
    var contentSize: CGFloat {
        return taskDetailViewController!.contentSize + taskTitleView.bounds.height + 8
    }
    
    var tagCollectionViewController: TagCollectionViewController!
    var taskDetailViewController: MoreOptionsViewController!
    var newTaskViewController: NewTaskViewController!
    
    var viewModel: TaskCreationViewModel!
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewController)))
        return view
    }()
    
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
    
    func present(_ taskDetailViewController: MoreOptionsViewController) {
        self.taskDetailViewController = taskDetailViewController
        
        addChild(taskDetailViewController)
        taskDetailView.addSubview(taskDetailViewController.view)
        
        taskDetailViewController.view.layer.cornerRadius = 6.3
        taskDetailViewController.view.layer.masksToBounds = true
        taskDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskDetailViewController.view.rightAnchor.constraint(equalTo: taskDetailView.rightAnchor),
            taskDetailViewController.view.topAnchor.constraint(equalTo: taskDetailView.topAnchor),
            taskDetailViewController.view.leftAnchor.constraint(equalTo: taskDetailView.leftAnchor),
            taskDetailViewController.view.bottomAnchor.constraint(equalTo: taskDetailView.bottomAnchor)
            ])
        
        taskDetailViewController.didMove(toParent: self)
    }
    
    func present(_ taskTitleViewController: NewTaskViewController) {
        self.newTaskViewController = taskTitleViewController
        
        addChild(taskTitleViewController)
        taskTitleView.addSubview(taskTitleViewController.view)
        
        taskTitleViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskTitleViewController.view.rightAnchor.constraint(equalTo: taskTitleView.rightAnchor),
            taskTitleViewController.view.topAnchor.constraint(equalTo: taskTitleView.topAnchor),
            taskTitleViewController.view.leftAnchor.constraint(equalTo: taskTitleView.leftAnchor),
            taskTitleViewController.view.bottomAnchor.constraint(equalTo: taskTitleView.bottomAnchor)
            ])
        
        newTaskViewController.didMove(toParent: self)
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
    
    @objc func dismissViewController() {
        viewModel.delegate?.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Task"
        configureShadows(in: whiteBackgroundView)
        configureShadows(in: taskDetailView)
        configureShadows(in: taskTitleView)
        
        whiteBackgroundView.layer.zPosition = 10
        tagCollectionView.layer.zPosition = 10
        taskContainerView.layer.zPosition = 5
        
        let blur = blurView
        blur.frame = view.frame
        view.insertSubview(blur, at: 0)
        
//        addGestureRecognizersForAnimations()
        
        viewModel.delegate?.viewDidLoad()
        taskDetailViewController.accessibilityElementsHidden = true
    }
    
    private func configureShadows(in view: UIView) {
        view.layer.cornerRadius = 6.3
        view.tintColor = UIColor.white
        
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.masksToBounds = false
        view.layer.shadowColor = CGColor.shadowColor
        view.layer.shadowOpacity = 0.2
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
        taskContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        taskContainerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        animateOrReverseRunningTransition(state: !state, duration: duration)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
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
    
    private func addTaskContainerAnimation(for state: State, with duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
            switch state {
            case .collapsed:
                self?.taskContainerViewTopConstraint.constant = -210
            case .expanded:
                self?.taskContainerViewTopConstraint.constant = 0
                
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

extension TaskCreationFrameViewController: TaskCreationUIDelegate {
    
    func presentMoreOptions() {
        guard state == .collapsed else { return }
        animateOrReverseRunningTransition(state: .expanded, duration: duration)
        taskDetailViewController.accessibilityElementsHidden = false
    }
    
    func hideMoreOptions() {
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
