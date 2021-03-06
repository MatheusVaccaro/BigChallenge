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
    @IBOutlet weak var tagDetailsView: UIView!
    
    @IBOutlet weak var detailsTableHeightConstraint: NSLayoutConstraint!
    var viewModel: TagCreationViewModel!
    
    var addTagTitleViewController: AddTagTitleViewController!
    var addTagColorsViewController: AddTagColorsViewController!
    var addTagDetailsViewController: AddDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate?.viewDidLoad()
        applyBlur()
        tagDetailsView.layer.cornerRadius = 6.3
        
        addTagDetailsViewController.view.layer.cornerRadius = 6.3
        addTagDetailsViewController.tableView.layer.cornerRadius = 6.3
        detailsTableHeightConstraint.constant =
            addTagDetailsViewController.contentHeight
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = ReefColors.largeTitle
        
        addTagColorsViewController.delegate = self
        addTagDetailsViewController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        detailsTableHeightConstraint.constant =
            addTagDetailsViewController.contentHeight
        print(detailsTableHeightConstraint.constant)
    }
    
    func present(_ addTagTitleViewController: AddTagTitleViewController,
                 _ addTagColorsViewController: AddTagColorsViewController,
                 _ addTagDetailsViewController: AddDetailsViewController) {
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
        tagDetailsView.addSubview(addTagDetailsViewController.view)
        
        addTagDetailsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addTagDetailsViewController.tableView.isScrollEnabled = true
        
        NSLayoutConstraint.activate([
            addTagDetailsViewController.view.rightAnchor.constraint(equalTo: tagDetailsView.rightAnchor),
            addTagDetailsViewController.view.topAnchor.constraint(equalTo: tagDetailsView.topAnchor),
            addTagDetailsViewController.view.leftAnchor.constraint(equalTo: tagDetailsView.leftAnchor),
            addTagDetailsViewController.view.bottomAnchor.constraint(equalTo: tagDetailsView.bottomAnchor)
            ])
    }
    
    @objc func cancelAddTag() {
        viewModel.cancelAddTag()
    }
    
    @objc func dismissKeyboard() {
        addTagTitleViewController.tagTitleTextField.resignFirstResponder()
    }
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: ReefColors.blurStyle)
        let view = UIVisualEffectView(effect: blurEffect)
        
        return view
    }()
    
    private func applyBlur() {
        //only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled {
            blurView.tintColor = ReefColors.cellIcons
        }

        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if !blurView.isDescendant(of: view) {
            view.insertSubview(blurView, at: 0)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelAddTag))
        blurView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        blurView.addGestureRecognizer(panGesture)
    }
    
    private func removeBlur() {
        blurView.removeFromSuperview()
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancelAddTag()
        return true
    }

}

extension TagCreationFrameViewController: AddTagColorsDelegate {
    func addTagColorsDidSelectColor() {
        addTagTitleViewController.tagTitleTextField.resignFirstResponder()
    }
}

extension TagCreationFrameViewController: AddTagDetailsDelegate {
    func addTagDetailsDidBecomeFirstResponder() {
        addTagTitleViewController.tagTitleTextField.resignFirstResponder()
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
