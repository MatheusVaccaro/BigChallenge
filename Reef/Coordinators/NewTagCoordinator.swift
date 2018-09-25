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
    fileprivate var addTagColorsViewController: AddTagColorsViewController!
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
        //View Comtrollers
        addTagTitleViewController = AddTagTitleViewController.instantiate()
        addTagColorsViewController = AddTagColorsViewController.instantiate()
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        
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
        moreOptionsViewController!.viewModel = addTagDetailsViewModel
        
        creationFrameViewModel.delegate = self
        createTagFrameViewController.present(addTagTitleViewController, addTagColorsViewController, moreOptionsViewController)
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

extension NewTagCoordinator: TagCreationDelegate {
    func viewDidLoad() {
        //TODO
    }
    
    func didAddTag() {
        homeScreen.dismissAddTag()
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
        
        presenter.pushViewController(inputView!, animated: true)
    }
}

extension NewTagCoordinator {
//    func viewDidLoad(in viewController: CreationFrameViewController) {
//        viewController.setFrameContent(viewController: createTagViewController!)
//    }
}
