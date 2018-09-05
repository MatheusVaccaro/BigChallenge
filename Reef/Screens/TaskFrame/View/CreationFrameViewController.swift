//
//  TaskFrameViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 28/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import NotificationCenter

protocol CreationFramePresentable {
    func didTapMoreOptionsButton(_ sender: UIButton)
}

protocol CreationFrameViewControllerDelegate: class {
    func viewDidLoad(in viewController: CreationFrameViewController)
}

extension CreationFrameViewControllerDelegate {
    func viewDidLoad(in viewController: CreationFrameViewController) { }
}

class CreationFrameViewController: UIViewController {

    typealias FrameContent = CreationFramePresentable & UIViewController
    
    // MARK: - Properties
    
    private var contentViewController: FrameContent?
    
    var viewModel: CreationFrameViewModelProtocol?
    private let disposeBag = DisposeBag()
    private var isShowingKeyboard = false
    
    weak var delegate: CreationFrameViewControllerDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Constraints
    
    @IBOutlet weak var buttonsBookshelfTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - TaskFrameViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        subscribeToEnableDoneButton()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CreationFrameViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CreationFrameViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        delegate?.viewDidLoad(in: self)
        print("+++ INIT CreationFrameViewController")
    }
    
    deinit {
        print("--- DEINIT CreationFrameViewController")
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        viewModel?.didTapCancelButton()
        contentViewController?.removeFromParent()
    }
    
    @IBAction func didTapMoreOptionsButton(_ sender: UIButton) {
        guard let contentViewController = contentViewController else { return }
        contentViewController.didTapMoreOptionsButton(sender)
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        viewModel?.didTapSaveButton()
        contentViewController?.removeFromParent()
    }
    
    // MARK: - Functions
    
    private func subscribeToEnableDoneButton() {
        viewModel?.doneButtonObservable.subscribe { [weak self] in
            self?.doneButton.isEnabled = $0.element!
            }.disposed(by: disposeBag)
    }
    
    func setFrameContent(viewController: FrameContent) {
        addChildViewController(viewController)
        
        containerView.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
        
        self.contentViewController = viewController
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isShowingKeyboard {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                isShowingKeyboard = true
                UIView.animate(withDuration: 1) {
                    self.buttonsBookshelfTopConstraint.constant -= keyboardSize.height
                    self.doneButtonBottomConstraint.constant += keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isShowingKeyboard {
            isShowingKeyboard = false
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 1) {
                    self.buttonsBookshelfTopConstraint.constant += keyboardSize.height
                    self.doneButtonBottomConstraint.constant -= keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: - StoryboardInstantiable

extension CreationFrameViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "CreationFrame"
    }
    
    static var viewControllerID: String {
        return "CreationFrameViewController"
    }
}
