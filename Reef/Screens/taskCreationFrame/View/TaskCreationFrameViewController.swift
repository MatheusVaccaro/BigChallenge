//
//  TaskCreationFrameViewController.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFrameViewController: UIViewController {

    @IBOutlet weak var taskContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var taskDetailView: UIView!
    @IBOutlet weak var taskTitleView: UIView!
    @IBOutlet weak var taskContainerView: UIView!
    
    var hiddenHeight: CGFloat {
        return taskTitleView.bounds.height
    }
    
    var contentSize: CGFloat {
        return taskDetailViewController!.contentSize + taskTitleView.bounds.height + 8
    }
    
    var tagCollectionViewController: TagCollectionViewController!
    var taskDetailViewController: MoreOptionsViewController!
    var newTaskViewController: NewTaskViewController!
    
    var viewModel: TaskCreationViewModel!
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewController)))
        return view
    }()
    
    func present(_ taskDetailViewController: MoreOptionsViewController) {
        self.taskDetailViewController = taskDetailViewController
        
        addChild(taskDetailViewController)
        taskDetailView.addSubview(taskDetailViewController.view)
        
        taskDetailViewController.view.layer.cornerRadius = 6.3
        taskDetailViewController.view.layer.masksToBounds = true
        taskDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            taskDetailViewController.view.rightAnchor.constraint(equalTo: taskDetailView.rightAnchor),
            taskDetailViewController.view.topAnchor.constraint(equalTo: taskDetailView.topAnchor),
            taskDetailViewController.view.leftAnchor.constraint(equalTo: taskDetailView.leftAnchor),
            taskDetailViewController.view.bottomAnchor.constraint(equalTo: taskDetailView.bottomAnchor)
            ])
        
        taskDetailViewController.didMove(toParent: self)
    }
    
    func present(_ taskTitleViewController: NewTaskViewController) {
        self.newTaskViewController = taskTitleViewController
        
        addChild(taskTitleViewController)
        taskTitleView.addSubview(taskTitleViewController.view)
        
        taskTitleViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskTitleViewController.view.rightAnchor.constraint(equalTo: taskTitleView.rightAnchor),
            taskTitleViewController.view.topAnchor.constraint(equalTo: taskTitleView.topAnchor),
            taskTitleViewController.view.leftAnchor.constraint(equalTo: taskTitleView.leftAnchor),
            taskTitleViewController.view.bottomAnchor.constraint(equalTo: taskTitleView.bottomAnchor)
            ])
        
        newTaskViewController.didMove(toParent: self)
    }
    
    func present(_ tagCollectionViewController: TagCollectionViewController) {
        self.tagCollectionViewController = tagCollectionViewController
        
        addChild(tagCollectionViewController)
        tagCollectionView.addSubview(tagCollectionViewController.view)
        
        tagCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tagCollectionViewController.view.rightAnchor.constraint(equalTo: tagCollectionView.rightAnchor),
            tagCollectionViewController.view.topAnchor.constraint(equalTo: tagCollectionView.topAnchor),
            tagCollectionViewController.view.leftAnchor.constraint(equalTo: tagCollectionView.leftAnchor),
            tagCollectionViewController.view.bottomAnchor.constraint(equalTo: tagCollectionView.bottomAnchor)
            ])
        
        tagCollectionViewController.didMove(toParent: self)
    }
    
    @IBAction func didTapAddTask(_ sender: Any) {
        viewModel.delegate?.didTapAddTask()
    }
    
    @IBAction func didPanAddTask(_ sender: Any) {
        viewModel.delegate?.didPanAddTask()
    }
    
    @objc func dismissViewController() {
        viewModel.delegate?.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        configureShadows(in: whiteBackgroundView)
        configureShadows(in: taskDetailView)
        configureShadows(in: taskTitleView)
        
        
        whiteBackgroundView.layer.zPosition = 10
        tagCollectionView.layer.zPosition = 10
        
        
        taskContainerView.layer.zPosition = 5
        
        let blur = blurView
        blur.frame = view.frame
        view.insertSubview(blur, at: 0)
        
        viewModel.delegate?.viewDidLoad()
    }
    
    private func configureShadows(in view: UIView) {
        view.layer.cornerRadius = 6.3
        view.tintColor = UIColor.white
        
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.masksToBounds = false
        view.layer.shadowColor = CGColor.shadowColor
        view.layer.shadowOpacity = 0.2
    }
    
}

extension TaskCreationFrameViewController {
    override func accessibilityPerformEscape() -> Bool {
        viewModel.performEscape()
        return true
    }
}

extension TaskCreationFrameViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "taskCreationFrame"
    }
    
    static var storyboardIdentifier: String {
        return "TaskCreation"
    }
}
