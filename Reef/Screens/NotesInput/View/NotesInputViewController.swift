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
        
        configureBackground()
        configureNavigationBarTitle()
        configureNotesInputTextView()
        
        print("+++ INIT NotesInputViewController")
    }
    
    deinit {
        print("--- DEINIT NotesInputViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.notes = notesInputTextView.text
    }
    
    // MARK: - Functions
    private func configureBackground() {
        let layer = CAGradientLayer()
        
        layer.frame = view.frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = UIColor.backGroundGradient
        layer.zPosition = -1
        
        view.layer.addSublayer(layer)
    }
    
    private func configureNotesInputTextView() {
        notesInputTextView.font = UIFont.font(sized: 22, weight: .semibold, with: .body, fontName: .barlow)
        notesInputTextView.placeholder = viewModel.textViewPlaceholder
        notesInputTextView.placeholderColor = UIColor.placeholder
        notesInputTextView.text = viewModel.notes
    }
    
    private func configureNavigationBarTitle() {
        title = viewModel.title
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
