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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        configureNavigationBar()
        configureNotesInputTextView()
        
        print("+++ INIT NotesInputViewController")
    }
    
    deinit {
        print("--- DEINIT NotesInputViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.notes = notesInputTextView.text
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .background
        notesInputTextView.becomeFirstResponder()
    }
    
    // MARK: - Functions
    private func configureNotesInputTextView() {
        notesInputTextView.font = UIFont.font(sized: 22, weight: .semibold, with: .body, fontName: .barlow)
        notesInputTextView.placeholder = viewModel.textViewPlaceholder
        notesInputTextView.placeholderColor = UIColor.placeholder
        notesInputTextView.text = viewModel.notes
    }
    
    private func configureNavigationBar() {
        title = viewModel.title
        navigationController?.navigationBar.barTintColor = .background
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
