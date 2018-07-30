//
//  NewTaskViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UITextView_Placeholder

class NewTaskViewController: UIViewController, TaskFramePresentable {
    
    // MARK: - Properties
    
    var viewModel: NewTaskViewModelProtocol?
    var tagCollectionViewModel: TagCollectionViewModel?
    fileprivate var tagCollectionViewController: TagCollectionViewController!
    private let disposeBag = DisposeBag()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var taskNotesTextView: UITextView!
    @IBOutlet weak var tagCollectionContainerView: UIView!
    
    // MARK: - NewTaskViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        configureWithViewModel()
        configureTagCollectionViewController()
        configureTaskTitleTextView()
        configureTaskNotesTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        taskTitleTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        viewModel?.didTapCancelButton()
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        guard let taskTitle = taskTitleTextView.text else { return }
        viewModel?.taskTitleText = taskTitle
        
        guard let taskNotes = taskNotesTextView.text else { return }
        viewModel?.taskNotesText = taskNotes
        
        viewModel?.didTapDoneButton()
    }
    
    @IBAction func didTapMoreOptionsButton(_ sender: UIButton) {
    }
    
    // MARK: - Functions
    
    private func configureWithViewModel() {
        guard let viewModel = viewModel else { return }
        if let taskTitle = viewModel.taskTitle() {
            taskTitleTextView.text = taskTitle
        }
    }
    
    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureTagCollectionViewController() {
        let tagCollectionViewController = TagCollectionViewController.instantiate()
        tagCollectionViewController.viewModel = tagCollectionViewModel
        addChildViewController(tagCollectionViewController)
        tagCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.tagCollectionViewController = tagCollectionViewController
        tagCollectionContainerView.addSubview(tagCollectionViewController.view)
        
        NSLayoutConstraint.activate([
            tagCollectionViewController.view
                .leadingAnchor.constraint(equalTo: tagCollectionContainerView.leadingAnchor),
            tagCollectionViewController.view
                .trailingAnchor.constraint(equalTo: tagCollectionContainerView.trailingAnchor),
            tagCollectionViewController.view
                .topAnchor.constraint(equalTo: tagCollectionContainerView.topAnchor),
            tagCollectionViewController.view
                .bottomAnchor.constraint(equalTo: tagCollectionContainerView.bottomAnchor)
            ])
        
        tagCollectionViewController.didMove(toParentViewController: self)
        
        tagCollectionViewController.viewModel.selectedTagsObservable.subscribe { event in
            self.viewModel?.selectedTags = event.element!
            print("selected tags are: \(event.element!.map {$0.title})")
            }.disposed(by: disposeBag)
    }
    
    private func configureTaskTitleTextView() {
        taskTitleTextView.textContainer.lineBreakMode = .byTruncatingTail
        taskTitleTextView.placeholder = "fon"
    }
    
    private func configureTaskNotesTextView() {
        taskNotesTextView.textContainer.lineBreakMode = .byTruncatingTail
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
