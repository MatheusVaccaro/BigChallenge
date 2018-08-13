//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class HomeScreenViewController: UIViewController {
    
    weak var delegate: HomeScreenViewModelDelegate?
    var viewModel: HomeScreenViewModel!
    
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var taskListContainerView: UIView!
    @IBOutlet weak var bigTitle: UILabel!

    fileprivate var taskListViewController: TaskListViewController!
    fileprivate var tagCollectionViewController: TagCollectionViewController!

    private let disposeBag = DisposeBag()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.frame = view.frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = UIColor.backGroundGradient
        layer.zPosition = -1
        
        return layer
    }()
    
    lazy var titleGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        
        return layer
    }()
    
    lazy var maskLabel: UILabel = {
        let ans = UILabel()
        
        ans.textAlignment = bigTitle.textAlignment
        ans.font = bigTitle.font
        
        return ans
    }()
    
    lazy var gradientView: UIView = {
        let gradientView = UIView(frame: view.bounds)
        
        gradientView.isUserInteractionEnabled = false
        gradientView.layer.addSublayer(titleGradient)
        gradientView.addSubview(maskLabel)
        gradientView.mask = maskLabel
        
        return gradientView
    }()
    
    override func viewDidLayoutSubviews() {
        gradientView.frame = bigTitle.frame
        titleGradient.frame = gradientView.bounds
        maskLabel.frame = gradientView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        bigTitle.textColor = UIColor.clear
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        view.layer.addSublayer(gradientLayer) // background gradient layer
        view.addSubview(gradientView)
        
        observeSelectedTags()
        observeClickedAddTag()
        userActivity = viewModel.userActivity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bigTitle.font =
            UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            if let taskListViewController = segue.destination as? TaskListViewController {
                let taskListViewModel = viewModel.taskListViewModel
                taskListViewModel.shouldAddTask.subscribe { event in
                    if let shouldAddTask = event.element {
                        if shouldAddTask {
                            self.delegate?
                                .willAddTask(selectedTags: self.tagCollectionViewController.viewModel.selectedTags)
                        }
                    }
                }.disposed(by: disposeBag)
                taskListViewController.viewModel = taskListViewModel
                self.taskListViewController = taskListViewController
            }
        } else if segue.identifier == "tagCollectionSegue" {
            if let tagCollectionViewController = segue.destination as? TagCollectionViewController {
                let tagCollectionViewModel =
                    viewModel.tagCollectionViewModel
                tagCollectionViewController.viewModel = tagCollectionViewModel
                self.tagCollectionViewController = tagCollectionViewController
            }
        }
    }
    
    fileprivate func observeClickedAddTag() {
        tagCollectionViewController.addTagEvent?.subscribe { _ in
            self.delegate?.willAddTag()
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeSelectedTags() {
        tagCollectionViewController.viewModel.selectedTagsObservable
            .subscribe { event in
                self.viewModel.updateSelectedTagsIfNeeded(event.element)
                self.configureBigTitle()
                if let activity = self.userActivity { self.updateUserActivityState(activity) }
                self.taskListViewController.viewModel.filterTasks(with: event.element!)
            }.disposed(by: disposeBag)
    }
    
    func configureBigTitle() {
        bigTitle.text = viewModel.bigTitleText
        maskLabel.text = viewModel.bigTitleText
        
        titleGradient.colors = bigTitleColors
    }
    
    var bigTitleColors: [CGColor] {
        return viewModel.selectedTags.isEmpty
            ? [UIColor.black.cgColor, UIColor.black.cgColor]
            : TagModel.tagColors[ Int(viewModel.selectedTags.first!.color) ]
    }
    
    @IBAction func didTapBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel.unSelectBigTitle(tag: tag)
        }
    }
    
    @IBAction func didLongpressBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            tagCollectionViewController.presentActionSheet(for: tag)
        }
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        viewModel.updateUserActivity(activity)
    }
}

extension HomeScreenViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "HomeScreenViewController"
    }
    
    static var storyboardIdentifier: String {
        return "HomeScreen"
    }
}
