//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

public protocol TaskTableViewCellSwipeDelegate: class {
    func didSwipeFromLeftToRight(in cell: TaskTableViewCell)
    func didSwipeFromRightToLeft(in cell: TaskTableViewCell)
}

public class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Animations Properties
    private let duration: TimeInterval = 0.5
    private var animationDistance: CGFloat!
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted: CGFloat = 0
    private let minimunProgressToCompleteAnimation: CGFloat = 0.15
    private var initialTranslationX: CGFloat!
    private var swipeDirection: SwipeDirection = .none {
        didSet {
            print(swipeDirection)
        }
    }
    
    weak var swipeDelegate: TaskTableViewCellSwipeDelegate?
    
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
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGradient))
//        tapView.addGestureRecognizer(tapRecognizer)
        
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
    
    private func addCellClosingAnimation(with duration: TimeInterval, target: UIView, completion: (() -> Void)?) {
        let topAuxView = UIView(frame: CGRect(x: target.bounds.minX,
                                              y: target.bounds.minY - target.bounds.midY,
                                              width: target.bounds.width,
                                              height: target.bounds.height/2))
        topAuxView.backgroundColor = ReefColors.background
        target.addSubview(topAuxView)
        
        let bottomAuxView = UIView(frame: CGRect(x: target.bounds.minX,
                                                 y: target.bounds.maxY,
                                                 width: target.bounds.width,
                                                 height: target.bounds.height/2))
        bottomAuxView.backgroundColor = ReefColors.background
        target.addSubview(bottomAuxView)
        let completionAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            topAuxView.frame.origin.y += topAuxView.frame.height
            bottomAuxView.frame.origin.y -= bottomAuxView.frame.height
        }
        completionAnimator.addCompletion { _ in
            completion?()
        }
        completionAnimator.startAnimation(afterDelay: 0.5)
    }

    private func addLeftToRightSwipeAnimation(with duration: TimeInterval) {
        let imageName: String = viewModel.taskIsCompleted ?
            "uncomplete" : "complete"
        let backgroundColor: UIColor = viewModel.taskIsCompleted ?
            ReefColors.uncompleteYellow : ReefColors.completeGreen
        let taskText: String = viewModel.taskIsCompleted ?
            Strings.Task.Cell.Swipe.Text.readmitted : Strings.Task.Cell.Swipe.Text.completed
        let taskStatus: String = viewModel.taskIsCompleted ?
            Strings.Task.Cell.Swipe.Status.readmitted : Strings.Task.Cell.Swipe.Status.completed
        
        let pullView = UIView(frame: CGRect(x: -contentView.frame.width,
                                            y: contentView.frame.minY,
                                            width: contentView.frame.width,
                                            height: contentView.frame.height))
        contentView.addSubview(pullView)
        
        pullView.backgroundColor = backgroundColor
        
        let completeImageView = UIImageView(image: UIImage(named: imageName))
        completeImageView.translatesAutoresizingMaskIntoConstraints = false
        pullView.addSubview(completeImageView)
        completeImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        completeImageView.centerYAnchor.constraint(equalTo: pullView.centerYAnchor).isActive = true
        completeImageView.trailingAnchor.constraint(equalTo: pullView.trailingAnchor,
                                                    constant: -12).isActive = true
        completeImageView.widthAnchor.constraint(equalTo: completeImageView.heightAnchor,
                                                 multiplier: 1.5).isActive = true
        
        let taskTextLabel = UILabel(frame: CGRect.zero)
        taskTextLabel.text = taskText
        taskTextLabel.textColor = .white
        taskTextLabel.font = UIFont.font(sized: 17.0,
                                         weight: FontWeight.mediumItalic,
                                         with: .body,
                                         fontName: .barlow)
        
        let taskStatusLabel = UILabel(frame: CGRect.zero)
        taskStatusLabel.text = taskStatus
        taskStatusLabel.textColor = .white
        taskStatusLabel.font = UIFont.font(sized: 13.0,
                                           weight: .medium,
                                           with: .body,
                                           fontName: .barlow)
        
        let stackView = UIStackView(arrangedSubviews: [taskTextLabel, taskStatusLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        stackView.spacing = 3
        
        pullView.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: pullView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: pullView.leadingAnchor, constant: 17).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: completeImageView.leadingAnchor,
                                            constant: -17).isActive = true
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [unowned self] in
            self.contentView.frame.origin.x += self.contentView.frame.width
        }
        animator.addCompletion { [unowned self] status in
            self.runningAnimators.removeAll()
            if status == .end {
                self.addCellClosingAnimation(with: 0.5, target: pullView, completion: { [unowned self] in
                    self.swipeDelegate?.didSwipeFromLeftToRight(in: self)
                })
            }
        }
        runningAnimators.append(animator)
    }
    
    private func addRightToLeftSwipeAnimation(with duration: TimeInterval) {
        let pullView = UIView(frame: CGRect(x: contentView.frame.width,
                                            y: contentView.frame.minY,
                                            width: contentView.frame.width,
                                            height: contentView.frame.height))
        contentView.addSubview(pullView)
        
        pullView.backgroundColor = ReefColors.deleteRed
        
        let trashImageView = UIImageView(image: UIImage(named: "trash"))
        trashImageView.translatesAutoresizingMaskIntoConstraints = false
        pullView.addSubview(trashImageView)
        trashImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        trashImageView.centerYAnchor.constraint(equalTo: pullView.centerYAnchor).isActive = true
        trashImageView.leadingAnchor.constraint(equalTo: pullView.leadingAnchor, constant: 12).isActive = true
        trashImageView.widthAnchor.constraint(equalTo: trashImageView.heightAnchor).isActive = true
        
        let taskTextLabel = UILabel(frame: CGRect.zero)
        taskTextLabel.text = Strings.Task.Cell.Swipe.Text.deleted
        taskTextLabel.textColor = .white
        taskTextLabel.font = UIFont.font(sized: 17.0,
                                         weight: FontWeight.mediumItalic,
                                         with: .body,
                                         fontName: .barlow)
        
        let taskStatusLabel = UILabel(frame: CGRect.zero)
        taskStatusLabel.text = Strings.Task.Cell.Swipe.Status.deleted
        taskStatusLabel.textColor = .white
        taskStatusLabel.font = UIFont.font(sized: 13.0,
                                           weight: .medium,
                                           with: .body,
                                           fontName: .barlow)
        
        let stackView = UIStackView(arrangedSubviews: [taskTextLabel, taskStatusLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .trailing
        stackView.spacing = 3
        
        pullView.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: pullView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: trashImageView.trailingAnchor,
                                           constant: 17).isActive = true
        stackView.trailingAnchor.constraint(equalTo: pullView.trailingAnchor, constant: -17).isActive = true
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [unowned self] in
            self.contentView.frame.origin.x -= self.contentView.frame.width
        }
        animator.addCompletion { [unowned self] status in
            self.runningAnimators.removeAll()
            if status == .end {
                self.addCellClosingAnimation(with: 0.5, target: pullView, completion: { [unowned self] in
                    self.swipeDelegate?.didSwipeFromRightToLeft(in: self)
                })
            }
        }
        runningAnimators.append(animator)
    }
    
    // MARK: Gesture Recognizers
    func addGestureRecognizersForAnimations() {
        animationDistance = contentView.frame.width
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(handleTapGesture(_:))))
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
            addLeftToRightSwipeAnimation(with: duration)
        case .rightToLeft:
            addRightToLeftSwipeAnimation(with: duration)
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
