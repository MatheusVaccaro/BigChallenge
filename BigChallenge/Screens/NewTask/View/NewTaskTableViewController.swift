//
//  NewTaskTableViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 27/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class NewTaskTableViewController: UITableViewController {

    // MARK: - Properties
    
    var viewModel: NewTaskViewModel?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var deleteTaskButton: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    // MARK: - TableViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        configureWithViewModel()
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
        
        titleTextField.text = viewModel.task?.title
        titleTextField.placeholder = viewModel.titleTextFieldPlaceHolder
        deleteTaskButton.text = viewModel.deleteButtonTitle
        navigationItem.title = viewModel.navigationItemTitle
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
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
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
