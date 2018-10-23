//
//  NewTaskViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import UITextView_Placeholder

class NewTaskViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: NewTaskViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var taskTitleTextView: VerticallyCenteredTextView!
    @IBOutlet weak var taskDetailsButton: UIButton!
    @IBOutlet weak var doneButton: UIView!
    @IBOutlet weak var doneButtonLabel: UILabel!
    @IBOutlet weak var rightButtonView: UIView!
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.frame = view.frame
        layer.frame.size.width = 10
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        
        return layer
    }()
    
    // MARK: - NewTaskViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.clipsToBounds = true
        
        view.backgroundColor = .tagsBackground
        
        configureDoneButton()
        configureWithViewModel()
        configureTaskTitleTextView()
        configureViewDesign()
        loadViewModel()
        doneButton.isHidden = true
        
        userActivity = viewModel.userActivity
        userActivity?.becomeCurrent()
        
        taskTitleTextView.delegate = self
        
        view.isAccessibilityElement = true
        (view as! NewTaskView).delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        taskTitleTextView.font = UIFont.font(sized: 17, weight: .medium, with: .body)
        doneButtonLabel.font = UIFont.font(sized: 14, weight: .medium, with: .caption2)
        doneButtonLabel.sizeToFit()
        
        taskTitleTextView.setNeedsLayout()
        taskTitleTextView.layoutIfNeeded()
        taskDetailsButton.setNeedsLayout()
        taskDetailsButton.layoutIfNeeded()
    }
    
    // MARK: - IBActions
    @IBAction func didClickDetailsButton(_ sender: Any) {
        taskTitleTextView.resignFirstResponder()
        viewModel.shouldPresentDetails(true)
        doneButton.isHidden = false
        taskDetailsButton.isHidden = true
    }
    
    @IBAction func didClickDoneButton(_ sender: Any) {
        _ = createTaskIfPossible()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        taskTitleTextView.becomeFirstResponder()
    }
    
    func loadViewModel() {
        taskTitleTextView.text = viewModel.taskTitleText
        gradientLayer.colors = viewModel.taskColors
    }
    
    func cancelAddTask() {
        taskTitleTextView.resignFirstResponder()
        viewModel.edit(nil)
        doneButton.isHidden = true
        taskDetailsButton.isHidden = false
    }
    
    func start() {
        taskTitleTextView.becomeFirstResponder()
    }
    
    private func createTaskIfPossible() -> Bool {
        guard taskTitleTextView.text != "" else { return false }
        taskTitleTextView.resignFirstResponder()
        viewModel.shouldCreateTask()
        doneButton.isHidden = true
        taskDetailsButton.isHidden = false
        return true
    }
    
    // MARK: - Functions
    private func configureDoneButton() {
        doneButtonLabel.text = Strings.General.done
        doneButtonLabel.textColor = .white
        doneButtonLabel.adjustsFontSizeToFitWidth = true
        
        doneButton.backgroundColor = .doneButtonBackground
        doneButton.layer.cornerRadius = 6.3
        
        taskDetailsButton.setImage(UIImage(named: "option")?.withRenderingMode(.alwaysTemplate), for: .normal)
        taskDetailsButton.tintColor = .placeholder
    }
    
    private func configureWithViewModel() {
        taskTitleTextView.text = viewModel.taskTitleText
        gradientLayer.colors = viewModel.taskColors
    }
    
    private func configureTaskTitleTextView() {
        taskTitleTextView.placeholderColor = UIColor.cellIcons.withAlphaComponent(0.5)
        taskTitleTextView.textColor = .taskTitleLabel
        taskTitleTextView.keyboardAppearance = UIColor.keyboardAppearance
        taskTitleTextView.placeholder = Strings.Task.CreationScreen.taskTitlePlaceholder
        
        taskTitleTextView.textContainer.lineFragmentPadding = 0
    }
    
    private func configureViewDesign() {
        view.layer.cornerRadius = 6.3
        view.tintColor = .white
    }
}

// MARK: - StoryboardInstantiable

class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

extension NewTaskViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "NewTask"
    }
    
    static var viewControllerID: String {
        return "NewTaskViewController"
    }
}

extension NewTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        viewModel.taskTitleText = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.shouldPresentDetails(false)
        doneButton.isHidden = true
        taskDetailsButton.isHidden = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return createTaskIfPossible()
        } else {
            return true
        }
    }
}

extension NewTaskViewController: NewTaskViewDelegate {
    var taskTitle: String? {
        return viewModel.taskTitleText
    }
    
    var canCreateTask: Bool {
        guard let text = viewModel.taskTitleText else { return false }
        return text != ""
    }
    
    var isPresentingMoreDetails: Bool {
        return taskDetailsButton.isHidden
    }
    
    func presentDetails() {
        self.didClickDetailsButton(taskDetailsButton)
    }
    
    func doneEditing() {
        self.didClickDoneButton(doneButton)
    }
}

extension NewTaskViewController: NewTaskViewModelDelegate {
    func didUpdateColors() {
        gradientLayer.colors = viewModel.taskColors
    }
}
