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

class NewTagCoordinator: Coordinator {
    
    fileprivate let presenter: UINavigationController
    var childrenCoordinators: [Coordinator]
    
    fileprivate var createTagFrameViewController: TagCreationFrameViewController!
    fileprivate var addTagTitleViewController: AddTagTitleViewController!
    fileprivate var moreOptionsViewController: MoreOptionsViewController!
    fileprivate let model: TagModel
    fileprivate var tag: Tag? // ???
    
    fileprivate let homeScreen: HomeScreenViewController
    
    weak var delegate: CoordinatorDelegate?
    
    init(tag: Tag? = nil, presenter: UINavigationController, model: TagModel, in viewController: HomeScreenViewController) {
        self.model = model
        self.presenter = presenter
        self.childrenCoordinators = []
        self.tag = tag
        
        self.homeScreen = viewController
    }
    
    func start() {
        createTagFrameViewController = TagCreationFrameViewController.instantiate()
        homeScreen.setupAddTag(viewController: createTagFrameViewController)
        // New Tag
        addTagTitleViewController = AddTagTitleViewController.instantiate()
        let addTagTitleViewModel = AddTagTitleViewModel()
        addTagTitleViewController.viewModel = addTagTitleViewModel
        // more options
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        let moreOptionsViewModel = MoreOptionsViewModel()
        moreOptionsViewModel.UIDelegate = moreOptionsViewController
        
        moreOptionsViewController!.viewModel = moreOptionsViewModel
    
        let creationFrameViewModel = TagCreationViewModel(tagModel: model, moreOptionsViewModel: moreOptionsViewModel)
        createTagFrameViewController.viewModel = creationFrameViewModel
        
        createTagFrameViewController.present(addTagTitleViewController)
    }
}

extension NewTagCoordinator {
    
    func didTapCancelButton() {
        dismissViewController()
    }
    
    func didTapSaveButton() {
        dismissViewController()
    }
    
    private func dismissViewController() {
        presenter.dismiss(animated: true, completion: nil)
        delegate?.shouldDeinitCoordinator(self)
    }
    
}

extension NewTagCoordinator {
//    func viewDidLoad(in viewController: CreationFrameViewController) {
//        viewController.setFrameContent(viewController: createTagViewController!)
//    }
}
