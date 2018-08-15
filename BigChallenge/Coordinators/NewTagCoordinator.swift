//
//  NewTagCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class NewTagCoordinator: Coordinator {
    
    fileprivate let presenter: UINavigationController
    var childrenCoordinators: [Coordinator]
    
    fileprivate var createTagViewController: CreateTagViewController?
    fileprivate var tagCreationFrameViewController: CreationFrameViewController?
    fileprivate let model: TagModel
    fileprivate var tag: Tag?
    fileprivate var modalPresenter: UINavigationController?
    
    weak var delegate: CoordinatorDelegate?
    
    init(tag: Tag? = nil, presenter: UINavigationController, model: TagModel) {
        self.model = model
        self.presenter = presenter
        self.childrenCoordinators = []
        self.tag = tag
    }
    
    func start() {
        // New Tag
        let createTagViewController = CreateTagViewController.instantiate()
        let newTagViewModel = NewTagViewModel(tag: tag,
                                              model: model)
        createTagViewController.viewModel = newTagViewModel
        self.createTagViewController = createTagViewController
        
        // Tag Frame
        let tagCreationFrameViewController = CreationFrameViewController.instantiate()
        let tagCreationFrameViewModel = TagCreationFrameViewModel(mainInfoViewModel: newTagViewModel, tagModel: model)
        tagCreationFrameViewModel.delegate = self
        tagCreationFrameViewController.viewModel = tagCreationFrameViewModel
        self.tagCreationFrameViewController = tagCreationFrameViewController

        tagCreationFrameViewController.configurePageViewController(with: [createTagViewController])
        
        // Modal Presenter
        let modalPresenter = UINavigationController(rootViewController: tagCreationFrameViewController)
        modalPresenter.isNavigationBarHidden = true
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true, completion: nil)
    }
}

extension NewTagCoordinator: CreationFrameViewModelDelegate {
    
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
