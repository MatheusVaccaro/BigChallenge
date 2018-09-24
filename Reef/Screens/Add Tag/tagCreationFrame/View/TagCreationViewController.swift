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
    
    func present(_ addTagTitleViewController: AddTagTitleViewController) {
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
