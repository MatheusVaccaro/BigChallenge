//
//  NotesInputViewController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 20/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import ReefKit

class NotesInputViewController: UIViewController {

    // MARK: - Properties
    var viewModel: NotesInputViewModel!
    
    // MARK: - IBOutlets
    @IBOutlet weak var notesInputTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ReefColors.background
        configureNavigationBar()
        configureNotesInputTextView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        #if DEBUG
        print("+++ INIT NotesInputViewController")
        #endif
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT NotesInputViewController")
    }
    #endif
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue {
            let keyboardHeight = keyboardSize.height
            bottomConstraint.constant += keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 16
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.notes = notesInputTextView.text
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = ReefColors.background
        notesInputTextView.becomeFirstResponder()
    }
    
    // MARK: - Functions
    private func configureNotesInputTextView() {
        notesInputTextView.font = UIFont.font(sized: 22, weight: .semibold, with: .body, fontName: .barlow)
        notesInputTextView.textColor = ReefColors.taskTitleLabel
        notesInputTextView.keyboardAppearance = ReefColors.keyboardAppearance
        notesInputTextView.placeholder = viewModel.textViewPlaceholder
        notesInputTextView.placeholderColor = ReefColors.placeholder
        notesInputTextView.text = viewModel.notes
    }
    
    private func configureNavigationBar() {
        title = viewModel.title
        navigationController?.navigationBar.barTintColor = ReefColors.background
    }
}

// MARK: - StoryboardInstantiable
extension NotesInputViewController: StoryboardInstantiable {
    
    static var viewControllerID: String {
        return "NotesInputViewController"
    }
    
    static var storyboardIdentifier: String {
        return "NotesInput"
    }
    
}
