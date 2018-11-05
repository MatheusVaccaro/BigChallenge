//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

public class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Animations Properties
    private let duration: TimeInterval = 0.25
    private var animationDistance: CGFloat!
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted: CGFloat = 0
    private let minimunProgressToCompleteAnimation: CGFloat = 0.2
    private var initialTranslationX: CGFloat!
    private var swipeDirection: SwipeDirection = .none {
        didSet {
            print(swipeDirection)
        }
    }
    
    // MARK: - Properties
    public static let identifier = "taskCell"
    
    private var viewModel: TaskCellViewModel!
    private var previousRect = CGRect.zero
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        
        return layer
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var gradientSideBar: UIView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var dateStringView: UIView!
    @IBOutlet weak var dateStringLabel: UILabel!
    @IBOutlet weak var tapView: UIView!
    
    // MARK: - TableViewCell Lifecycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        gradientSideBar.layer.addSublayer(gradientLayer)
        gradientSideBar.clipsToBounds = true
        
        taskTitleTextView.textContainerInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
        
        dateStringView.layer.cornerRadius = dateStringView.frame.height * 0.1
        dateStringLabel.textColor = ReefColors.cellTagLabel
        
        tagsLabel.textColor = ReefColors.cellTagLabel
        
        selectionStyle = .none
        configureAccessibility()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGradient))
        tapView.addGestureRecognizer(tapRecognizer)
        
        addGestureRecognizersForAnimations()
    }
    
    public override func layoutSubviews() {
        gradientLayer.frame = bounds
    }
    
    // MARK: - Functions
    public func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        tagsLabel.text = viewModel.tagsDescription
        
        if viewModel.shouldShowLocationIcon {
            locationIconImageView.image = UIImage(named: "locationIcon")!
                .withRenderingMode(.alwaysTemplate)
            locationIconImageView.tintColor = ReefColors.cellTagLabel
            locationIconImageView.isHidden = false
        } else {
            locationIconImageView.isHidden = true
        }
        
        if viewModel.shouldShowDateIcon {
            dateStringView.backgroundColor = viewModel.isTaskLate
                ? ReefColors.deleteRed
                : ReefColors.cellIcons
            dateStringLabel.textColor = viewModel.isTaskLate
                ? UIColor.white
                : ReefColors.cellTagLabel
            
            dateStringLabel.text = viewModel.dateString(with: "dd MMM")
            dateStringView.isHidden = false
        } else {
            dateStringView.isHidden = true
            dateStringView.backgroundColor = .clear
            dateStringLabel.text = ""
        }
        
        if viewModel.taskIsCompleted {
            gradientLayer.colors = [ReefColors.cellTagLabel.cgColor, ReefColors.cellTagLabel.cgColor]
            
            let textAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.thick.rawValue,
                NSAttributedString.Key.strikethroughColor : ReefColors.cellTagLabel,
                NSAttributedString.Key.foregroundColor : ReefColors.cellTagLabel,
                NSAttributedString.Key.font : UIFont.font(sized: 19, weight: .medium, with: .body)
            ]
            
            let str = NSAttributedString(string: viewModel.title, attributes: textAttributes)
            
            taskTitleTextView.attributedText = str
            
        } else {
            taskTitleTextView.textColor = UIColor.black
            gradientLayer.colors = viewModel.checkButtonGradient
            
            let textAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor : ReefColors.taskTitleLabel,
                NSAttributedString.Key.font : UIFont.font(sized: 19, weight: .medium, with: .body)
            ]
            
            let str = NSAttributedString(string: viewModel.title, attributes: textAttributes)
            
            taskTitleTextView.attributedText = str
        }
    }
    
    fileprivate func configureAccessibility() {
        gradientSideBar.accessibilityIgnoresInvertColors = true
    }
    
    @IBAction func didTapGradient(_ sender: UITapGestureRecognizer) {
        viewModel.toggleCompleteTask()
    }
    
}

extension TaskTableViewCell { // MARK: - Accessibility
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        taskTitleTextView.font = UIFont.font(sized: 19, weight: .medium, with: .body)
        dateStringLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
        tagsLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
        dateStringView.layer.cornerRadius = dateStringView.frame.height * 0.1
        gradientSideBar.setNeedsLayout()
        gradientSideBar.layoutIfNeeded()
    }
    
    public override var accessibilityLabel: String? {
        get {
            return viewModel!.title
        }
        set { }
    }
    
    public override var accessibilityValue: String? {
        get {
            
            var ans = ""
            
            if let tagsDescription = viewModel!.tagsDescription {
                ans.append(tagsDescription)
            }
            
            if let dateDescription = viewModel!.accessibilityDateString {
                ans.append(", \(dateDescription)")
            }
            
            if let locationDescription = viewModel!.locationDescription {
                ans.append(", \(locationDescription)")
            }
            
            return ans
        }
        set { }
    }
    
    public override var accessibilityHint: String? {
        get {
            return viewModel!.voiceOverHint
        }
        set { }
    }
    
    public override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let completeAction = UIAccessibilityCustomAction(name: viewModel!.completeActionTitle,
                                                             target: self,
                                                             selector: #selector(toggleCompleteAction))
            
            return [completeAction]
        }
        set { }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.allowsDirectInteraction
        }
        set { }
    }
    
    @objc private func toggleCompleteAction() {
        viewModel.toggleCompleteTask()
    }
}

// MARK: - Animations
extension TaskTableViewCell {

    private func addLeftToRightSwipeAnimation(with duration: TimeInterval, completionHandler: (() -> Void)?) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [unowned self] in
            self.contentView.frame.origin.x += self.contentView.frame.width/2
        }
        animator.addCompletion { [unowned self] _ in
            completionHandler?()
            self.runningAnimators.removeAll()
        }
        runningAnimators.append(animator)
    }
    
    private func addRightToLeftSwipeAnimation(with duration: TimeInterval, completionHandler: (() -> Void)?) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [unowned self] in
            self.contentView.frame.origin.x -= self.contentView.frame.width/2
        }
        animator.addCompletion { [unowned self] _ in
            completionHandler?()
            self.runningAnimators.removeAll()
        }
        runningAnimators.append(animator)
    }
        
    
    // MARK: Gesture Recognizers
    func addGestureRecognizersForAnimations() {
        animationDistance = contentView.frame.width
//        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
//                                                                action: #selector(handleTapGesture(_:))))
        contentView.addGestureRecognizer(PanDirectionGestureRecognizer(direction: .horizontal,
                                                                       target: self,
                                                                       action: #selector(handlePanGesture(_:))))
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        animateOrReverseRunningTransition(swipeDirection: .leftToRight, duration: duration)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: contentView)
        print(translation)
        switch recognizer.state {
        case .began:
            initialTranslationX = 0
        case .changed:
            let swipeDirection: SwipeDirection = translation.x >= initialTranslationX ? .leftToRight : .rightToLeft
            let swipeDirectionChanged: Bool = swipeDirection != self.swipeDirection ? true : false
            self.swipeDirection = swipeDirection
            if runningAnimators.isEmpty {
                startInteractiveTransition(swipeDirection: swipeDirection, duration: duration)
            } else if swipeDirectionChanged {
                self.runningAnimators.forEach({
                    $0.stopAnimation(false)
                    $0.finishAnimation(at: UIViewAnimatingPosition.start)
                })
            } else {
                let fraction = fractionComplete(swipeDirection: swipeDirection, translation: translation)
                updateInteractiveTransition(fractionComplete: fraction)
            }
        case .ended:
            let fraction = fractionComplete(swipeDirection: swipeDirection, translation: translation)
            continueInteractiveTransition(fractionComplete: fraction)
            swipeDirection = .none
        default:
            break
        }
    }
    
    // MARK: Animation Engine
    // Perform all animations with animators if not already running
    private func animateTransitionIfNeeded(swipeDirection: SwipeDirection, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        
        switch swipeDirection {
        case .leftToRight:
            addLeftToRightSwipeAnimation(with: duration, completionHandler: nil)
        case .rightToLeft:
            addRightToLeftSwipeAnimation(with: duration, completionHandler: nil)
        default:
            break
        }
    }
    
    // Starts transition if necessary or reverses it on tap
    private func animateOrReverseRunningTransition(swipeDirection: SwipeDirection, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(swipeDirection: swipeDirection, duration: duration)
            startAnimators()
        } else {
            reverseRunningAnimators()
        }
    }
    
    // Starts transition if necessary and pauses on pan .began
    private func startInteractiveTransition(swipeDirection: SwipeDirection, duration: TimeInterval) {
        animateTransitionIfNeeded(swipeDirection: swipeDirection, duration: duration)
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
        let timing = UICubicTimingParameters(animationCurve: .easeInOut)
        if cancel {
            runningAnimators.forEach {
                $0.isReversed = !$0.isReversed
                $0.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            }
        } else {
            runningAnimators.forEach {
                $0.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            }
        }
    }
    
    private func startAnimators() {
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
        for animator in runningAnimators {
            animator.pauseAnimation()
        }
    }
    
    private func fractionComplete(swipeDirection: SwipeDirection, translation: CGPoint) -> CGFloat {
        let translationX: CGFloat
        if swipeDirection == .leftToRight {
            translationX = translation.x
        } else {
            translationX = -translation.x
        }
        let fractionComplete = translationX / animationDistance + progressWhenInterrupted
        return fractionComplete
    }
}

private enum SwipeDirection {
    case rightToLeft
    case leftToRight
    case none
}
