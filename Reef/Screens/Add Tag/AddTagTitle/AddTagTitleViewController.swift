//
//  AddTagTitleViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

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

    }
    
    @IBAction func didPressDoneButton(_ sender: UIButton) {
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
