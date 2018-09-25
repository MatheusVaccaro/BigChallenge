//
//  TagCreationViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 21/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TagCreationFrameViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var tagTitleView: UIView!
    @IBOutlet weak var tagColorsView: UIView!
    @IBOutlet weak var tagMoreOptionsView: UIView!
    
    var viewModel: TagCreationViewModel!
    
    var addTagTitleViewController: AddTagTitleViewController!
    var addTagColorsViewController: AddTagColorsViewController!
    var addTagDetailsViewController: MoreOptionsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func present(_ addTagTitleViewController: AddTagTitleViewController,
                 _ addTagColorsViewController: AddTagColorsViewController,
                 _ addTagDetailsViewController: MoreOptionsViewController) {
        self.addTagTitleViewController = addTagTitleViewController
        
        addChild(addTagTitleViewController)
        tagTitleView.addSubview(addTagTitleViewController.view)
        
        addTagTitleViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTagTitleViewController.view.rightAnchor.constraint(equalTo: tagTitleView.rightAnchor),
            addTagTitleViewController.view.topAnchor.constraint(equalTo: tagTitleView.topAnchor),
            addTagTitleViewController.view.leftAnchor.constraint(equalTo: tagTitleView.leftAnchor),
            addTagTitleViewController.view.bottomAnchor.constraint(equalTo: tagTitleView.bottomAnchor)
            ])
        
        self.addTagColorsViewController = addTagColorsViewController
        
        addChild(addTagColorsViewController)
        tagColorsView.addSubview(addTagColorsViewController.view)
        
        addTagColorsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTagColorsViewController.view.rightAnchor.constraint(equalTo: tagColorsView.rightAnchor),
            addTagColorsViewController.view.topAnchor.constraint(equalTo: tagColorsView.topAnchor),
            addTagColorsViewController.view.leftAnchor.constraint(equalTo: tagColorsView.leftAnchor),
            addTagColorsViewController.view.bottomAnchor.constraint(equalTo: tagColorsView.bottomAnchor)
            ])
        
        self.addTagDetailsViewController = addTagDetailsViewController
        
        addChild(addTagDetailsViewController)
        tagMoreOptionsView.addSubview(addTagDetailsViewController.view)
        
        addTagDetailsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTagDetailsViewController.view.rightAnchor.constraint(equalTo: tagMoreOptionsView.rightAnchor),
            addTagDetailsViewController.view.topAnchor.constraint(equalTo: tagMoreOptionsView.topAnchor),
            addTagDetailsViewController.view.leftAnchor.constraint(equalTo: tagMoreOptionsView.leftAnchor),
            addTagDetailsViewController.view.bottomAnchor.constraint(equalTo: tagMoreOptionsView.bottomAnchor)
            ])

    }

}

extension TagCreationFrameViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "tagCreationFrame"
    }
    
    static var storyboardIdentifier: String {
        return "TagCreation"
    }
}
