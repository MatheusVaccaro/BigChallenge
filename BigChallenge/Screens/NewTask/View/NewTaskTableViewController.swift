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

        viewModel?.didTapDoneButton()
    }
    
    @IBAction func didEndEditingTitle(_ sender: Any) {
        // TODO find a better way to do this
        guard let text = titleTextField.text else { return }
        viewModel?.task.title = text
    }
    
    // MARK: - Functions
    
    private func configureWithViewModel() {
        guard let viewModel = viewModel else { return }
        
        titleTextField.text = viewModel.task.title
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
        return "NewTaskTableViewController"
    }
    
    static var storyboardName: String {
        return "NewTask"
    }
    
}
