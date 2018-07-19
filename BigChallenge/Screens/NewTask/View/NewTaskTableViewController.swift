//
//  NewTaskTableViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 27/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewTaskTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var viewModel: NewTaskViewModelProtocol?
    var tagCollectionViewModel: TagCollectionViewModel?
    fileprivate var tagCollectionViewController: TagCollectionViewController!
    private let disposeBag = DisposeBag()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var deleteTaskButton: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagCollectionContainerView: UIView!
    
    // MARK: - TableViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        configureWithViewModel()
        configureTagCollectionViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapCancelBarButtonItem(_ sender: Any) {
        viewModel?.didTapCancelButton()
    }
    
    @IBAction func didTapDoneBarButtonItem(_ sender: Any) {
        guard let titleText = titleTextField.text else { return }
        viewModel?.taskTitleTextField = titleText
        viewModel?.didTapDoneButton()
    }
    
    // MARK: - Functions
    private func configureWithViewModel() {
        guard let viewModel = viewModel else { return }
        
        titleTextField.text = viewModel.taskTitle()
        titleTextField.placeholder = viewModel.titleTextFieldPlaceholder()
        deleteTaskButton.text = viewModel.deleteButtonTitle()
        navigationItem.title = viewModel.navigationItemTitle()
    }
    
    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        if titleTextField.isEditing {
            titleTextField.resignFirstResponder()
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
            tagCollectionViewController.view.leadingAnchor.constraint(equalTo: tagCollectionContainerView.leadingAnchor),
            tagCollectionViewController.view.trailingAnchor.constraint(equalTo: tagCollectionContainerView.trailingAnchor),
            tagCollectionViewController.view.topAnchor.constraint(equalTo: tagCollectionContainerView.topAnchor),
            tagCollectionViewController.view.bottomAnchor.constraint(equalTo: tagCollectionContainerView.bottomAnchor)
            ])
        
        tagCollectionViewController.didMove(toParentViewController: self)
        
        tagCollectionViewController.viewModel.selectedTagsObservable.subscribe { event in
            self.viewModel?.selectedTags = event.element!
            print("selected tags are: \( event.element!.map {$0.title} )")
            }.disposed(by: disposeBag)

    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(in: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            viewModel?.didTapDeleteTaskButton()
        }
    }
}

// MARK: - StoryboardInstantiable

extension NewTaskTableViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return "NewTask"
    }
    
    static var viewControllerID: String {
        return "NewTaskTableViewController"
    }
}
