//
//  AddTagTitleViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

protocol AddTagDelegate: class {
    func didPressCreateTask()
}

class AddTagTitleViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tagTitleTextField: UITextField!
    @IBOutlet weak var tagTitleDoneButton: UIButton!
    
    // MARK: - Properties
    var viewModel: AddTagTitleViewModel!
    
    weak var delegate: AddTagDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 6.3
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.masksToBounds = false
        view.layer.shadowColor = CGColor.shadowColor
        view.layer.shadowOpacity = 0.2
        
        tagTitleTextField.delegate = self
        tagTitleTextField.text = viewModel.tagTitle
    }
    
    @IBAction func didPressDoneButton(_ sender: UIButton) {
        _ = viewModel.createTagIfPossible(tagTitleTextField.text!)
    }
}

extension AddTagTitleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return viewModel.createTagIfPossible(textField.text!)
    }
}

extension AddTagTitleViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "addTagTitle"
    }
    
    static var storyboardIdentifier: String {
        return "AddTagTitle"
    }
}
