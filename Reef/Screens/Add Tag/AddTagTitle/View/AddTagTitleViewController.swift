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
        
        configureViewDesign()
        configureTagTitleTextField()
        
        if let tagTitleView = view as? TagTitleView {
            tagTitleView.delegate = self
            tagTitleView.isAccessibilityElement = true
            tagTitleDoneButton.isAccessibilityElement = false
        }
    }
    
    private func configureViewDesign() {
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowColor = UIColor.shadow
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 11
        view.layer.shadowRadius = 6.3
    }
    
    private func configureAccessibility() {
        tagTitleDoneButton.isAccessibilityElement = false
        tagTitleDoneButton.accessibilityHint = Strings.Tag.CollectionScreen.VoiceOver.AddTag.hint
        tagTitleDoneButton.accessibilityLabel = Strings.Tag.CollectionScreen.VoiceOver.AddTag.label
    }
    
    private func configureTagTitleTextField() {
        tagTitleTextField.text = viewModel.tagTitle
        tagTitleTextField.placeholder = Strings.Tag.CreationScreen.tagTitlePlaceholder
        tagTitleTextField.delegate = self
    }
    
    @IBAction func didPressDoneButton(_ sender: UIButton) {
        _ = viewModel.createTagIfPossible(tagTitleTextField.text!)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tagTitleTextField.font = UIFont.font(sized: 22, weight: .semibold, with: .body, fontName: .barlow)
    }
}

extension AddTagTitleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return viewModel.createTagIfPossible(textField.text!)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 15
    }
}

extension AddTagTitleViewController: TagTitleViewAccessibilityDelegate {
    var shouldEnableCreateTask: Bool {
        return !(tagTitleTextField.text ?? "").isEmpty
    }
    
    func createTag() {
        didPressDoneButton(tagTitleDoneButton)
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

protocol TagTitleViewAccessibilityDelegate: class {
    var shouldEnableCreateTask: Bool { get }
    func createTag()
}

class TagTitleView: UIView {
    weak var delegate: TagTitleViewAccessibilityDelegate!
    
    override var accessibilityLabel: String? {
        get {
            return Strings.Tag.CreationScreen.VoiceOver.label
        }
        set { }
    }
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            guard delegate.shouldEnableCreateTask else { return nil  }
            
            let createAction = UIAccessibilityCustomAction(name: Strings.Task.CreationScreen.VoiceOver.CreateTaskAction,
                                                           target: self,
                                                           selector: #selector(handleCreateAction))
            
            return [createAction]
        }
        set { }
    }
    
    @objc func handleCreateAction() {
        delegate.createTag()
    }
}
