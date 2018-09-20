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

protocol NewTaskDelegate: class {
    func shouldPresentMoreOptions()
    func shouldHideMoreOptions()
    func didPressCreateTask()
}

class NewTaskViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: NewTaskViewModel!
    private let disposeBag = DisposeBag()

    weak var delegate: NewTaskDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var taskDetailsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
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
        
        configureWithViewModel()
        configureTaskTitleTextView()
        configureViewDesign()
        configureMoreOptionsButton()
        
        userActivity = viewModel.userActivity
        userActivity?.becomeCurrent()
        
        taskTitleTextView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - IBActions
    @IBAction func didClickDetailsButton(_ sender: Any) {
        taskTitleTextView.resignFirstResponder()
        delegate?.shouldPresentMoreOptions()
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
    
    func cancelAddTask() {
        taskTitleTextView.resignFirstResponder()
        viewModel.edit(nil)
    }
    
    private func createTaskIfPossible() -> Bool {
        guard taskTitleTextView.text != "" else { return false }
        taskTitleTextView.resignFirstResponder()
        viewModel.outputDelegate?.didPressCreateTask()
        delegate?.didPressCreateTask()
        doneButton.isHidden = true
        taskDetailsButton.isHidden = false
        return true
    }
    
    // MARK: - Functions
    private func configureMoreOptionsButton() {
        taskDetailsButton.setImage(UIImage(named: "option"), for: .normal)
        doneButton.setImage(UIImage(named: "DoneButtonAddTask"), for: .normal)
        doneButton.isHidden = true
    }
    
    private func configureWithViewModel() {
        taskTitleTextView.text = viewModel.taskTitleText
        gradientLayer.colors = viewModel.taskColors
    }
    
    private func configureTaskTitleTextView() {
        taskTitleTextView.font = UIFont.font(sized: 17, weight: .medium, with: .body)
        
        taskTitleTextView.placeholderColor = UIColor.lightGray.withAlphaComponent(0.5) //TODO set true color
        taskTitleTextView.placeholder = Strings.Task.CreationScreen.taskTitlePlaceholder
        
        taskTitleTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
    }
    
    private func configureViewDesign() {
        view.layer.cornerRadius = 6.3
        view.tintColor = UIColor.white
        
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.masksToBounds = false
        view.layer.shadowColor = CGColor.shadowColor
        view.layer.shadowOpacity = 0.2
    }
}

// MARK: - StoryboardInstantiable

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
        delegate?.shouldHideMoreOptions()
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

extension NewTaskViewController: NewTaskViewModelDelegate {
    func updateTextViewWith(text: String) {
        taskTitleTextView.text = text
    }
    
    func didUpdateColors() {
        gradientLayer.colors = viewModel.taskColors
    }
}
