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

class NewTaskViewController: UIViewController, CreationFramePresentable {
    
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
        
        configureWithViewModel()
        configureTagCollectionViewController()
        configureTaskTitleTextView()
        configureTaskNotesTextView()
        userActivity = viewModel!.userActivity
        userActivity?.becomeCurrent()
        
        taskTitleTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskTitleTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapMoreOptionsButton(_ sender: UIButton) {
    }
    
    // MARK: - Functions
    
    private func configureWithViewModel() {
        guard let viewModel = viewModel else { return }
        if let taskTitle = viewModel.taskTitle(),
            let taskNotes = viewModel.taskNotesText {
            taskTitleTextView.text = taskTitle
            taskNotesTextView.text = taskNotes
        }
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
        
        tagCollectionViewController.addTagEvent?.subscribe { _ in
            self.viewModel?.willAddTag()
        }.disposed(by: disposeBag)
    }
    
    private func configureTaskTitleTextView() {
        taskTitleTextView.font = UIFont.font(sized: 38.0, weight: .bold, with: .title1, fontName: .barlow)
        taskTitleTextView.placeholderColor = UIColor.lightGray.withAlphaComponent(0.5)
        taskTitleTextView.becomeFirstResponder()
        taskTitleTextView.placeholder = Strings.Task.CreationScreen.taskTitlePlaceholder
        taskTitleTextView.textContainerInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
    }
    
    private func configureTaskNotesTextView() {
        taskNotesTextView.delegate = self
        taskNotesTextView.font = UIFont.font(sized: 14, weight: .regular, with: .body)
        taskNotesTextView.textContainer.lineBreakMode = .byTruncatingTail
        taskNotesTextView.placeholderColor = UIColor.lightGray.withAlphaComponent(0.5)
        taskNotesTextView.placeholder = Strings.Task.CreationScreen.taskDescriptionPlaceholder
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
        if textView === taskTitleTextView {
            viewModel?.taskTitleText = textView.text
        } else {
            viewModel?.taskNotesText = textView.text
        }
    }
}