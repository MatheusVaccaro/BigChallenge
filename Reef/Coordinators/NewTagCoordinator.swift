//
//  NewTagCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import ReefKit

class NewTagCoordinator: NSObject, Coordinator {
    
    fileprivate let presenter: UINavigationController
    fileprivate var modalPresenter: UINavigationController!
    var childrenCoordinators: [Coordinator]
    
    fileprivate var createTagFrameViewController: TagCreationFrameViewController!
    fileprivate var addTagTitleViewController: AddTagTitleViewController!
    fileprivate var addTagColorsViewController: AddTagColorsViewController!
    fileprivate var tagDetailsViewController: AddDetailsViewController!
    fileprivate let model: TagModel
    fileprivate var tag: Tag?
    
    weak var delegate: CoordinatorDelegate?
    
    init(tag: Tag? = nil, presenter: UINavigationController, model: TagModel) {
        self.model = model
        self.presenter = presenter
        self.childrenCoordinators = []
        self.tag = tag
    }
    
    func start() {
        createTagFrameViewController = TagCreationFrameViewController.instantiate()
        
        //View Comtrollers
        addTagTitleViewController = AddTagTitleViewController.instantiate()
        addTagColorsViewController = AddTagColorsViewController.instantiate()
        tagDetailsViewController = AddDetailsViewController.instantiate()
        
        //viewModels
        let addTagTitleViewModel = AddTagTitleViewModel()
        let addTagColorsViewModel = AddTagColorsViewModel()
        let addTagDetailsViewModel = AddTagDetailsViewModel()
        
        let creationFrameViewModel = TagCreationViewModel(tagModel: model,
                                                          addTagTitleViewModel,
                                                          addTagColorsViewModel,
                                                          addTagDetailsViewModel)
        
        creationFrameViewModel.edit(tag)
        
        createTagFrameViewController.viewModel = creationFrameViewModel
        addTagTitleViewController.viewModel = addTagTitleViewModel
        addTagColorsViewController.viewModel = addTagColorsViewModel
        tagDetailsViewController!.viewModel = addTagDetailsViewModel
        
        creationFrameViewModel.delegate = self
        
        modalPresenter = UINavigationController(rootViewController: createTagFrameViewController)
        configureModalPresenter()
        
        presenter.present(modalPresenter, animated: true) {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
        }
    }
    
    private func configureModalPresenter() {
        modalPresenter.transitioningDelegate = self
        modalPresenter.navigationBar.setBackgroundImage(UIImage(), for: .default)
        modalPresenter.navigationBar.shadowImage = UIImage()
        modalPresenter.navigationBar.prefersLargeTitles = true
        modalPresenter.navigationBar.isTranslucent = true
        modalPresenter.view.backgroundColor = .clear
        modalPresenter.navigationBar.largeTitleTextAttributes =
            [ NSAttributedString.Key.font : UIFont.font(sized: 34,
                                                        weight: .bold,
                                                        with: .largeTitle,
                                                        fontName: .barlow),
        NSAttributedString.Key.foregroundColor : UIColor.largeTitleColor ]
        
        modalPresenter.modalPresentationStyle = .overCurrentContext
        modalPresenter.modalTransitionStyle = .crossDissolve
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        modalPresenter.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        presenter.dismiss(animated: true, completion: nil)
        delegate?.shouldDeinitCoordinator(self)
    }
}

extension NewTagCoordinator: UIViewControllerTransitioningDelegate {
    
}

extension NewTagCoordinator: TagCreationDelegate {
    func viewDidLoad() {
        createTagFrameViewController
            .present(addTagTitleViewController, addTagColorsViewController, tagDetailsViewController)
    }
    
    func didAddTag() {
        dismissViewController()
    }
    
    func shouldPresent(viewModel: IconCellPresentable) {
        var inputView: UIViewController?
        
        if let locationViewModel = viewModel as? LocationInputViewModel {
            let locationInput = LocationInputView.instantiate()
            locationInput.viewModel = locationViewModel
            inputView = locationInput
        } else if let dateViewModel = viewModel as? DateInputViewModel {
            let dateInput = DateInputViewController.instantiate()
            dateInput.viewModel = dateViewModel
            inputView = dateInput
        }
        
        if let inputView = inputView {
            modalPresenter.pushViewController(inputView, animated: true)
        }
    }
}
