//
//  HomeScreenViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Crashlytics
import RxCocoa
import RxSwift

class HomeScreenViewController: UIViewController {
    
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
        
        bigTitle.textColor = UIColor.clear
        bigTitle.font = UIFont.font(sized: 41, weight: .medium, with: .largeTitle)
        bigTitle.adjustsFontForContentSizeCategory = true
        
        view.layer.addSublayer(gradientLayer)
        view.addSubview(gradientView)
        
        configureEmptyState()
        observeSelectedTags()
        observeClickedAddTag()
        userActivity = viewModel.userActivity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        maskLabel.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        configureEmptyState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            if let taskListViewController = segue.destination as? TaskListViewController {
                let taskListViewModel = viewModel.taskListViewModel
                
                self.subscribe(to: taskListViewModel)
                
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
    
    fileprivate func subscribe(to taskListViewModel: TaskListViewModel) {
        taskListViewModel.shouldAddTask.subscribe { event in
            if let shouldAddTask = event.element, shouldAddTask {
                self.viewModel.delegate?
                    .willAddTask(selectedTags: self.tagCollectionViewController.viewModel.selectedTags)
                }
        }.disposed(by: disposeBag)
        
        taskListViewModel.shouldEditTask.subscribe() { task in
            if let task = task.element {
                self.viewModel.delegate?
                    .will(edit: task)
            }
        }.disposed(by: disposeBag)
        
        taskListViewModel.tasksObservable.subscribe { event in
            guard let tasks = event.element else { return }
            DispatchQueue.main.async {
                self.showEmptyState(tasks.0.isEmpty && tasks.1.isEmpty)
            }
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeClickedAddTag() {
        tagCollectionViewController.addTagEvent?.subscribe { _ in
            self.viewModel.delegate?.willAddTag()
        }.disposed(by: disposeBag)
    }
    
    fileprivate func observeSelectedTags() {
        tagCollectionViewController.viewModel.selectedTagsObservable
            .subscribe { event in
                guard let selectedTags = event.element else { return }
                self.viewModel.updateSelectedTagsIfNeeded(selectedTags)
                self.configureBigTitle()
                if let activity = self.userActivity { self.updateUserActivityState(activity) }
                self.taskListViewController.viewModel.filterTasks(with: selectedTags)
                
                if !selectedTags.isEmpty {                
                    Answers.logCustomEvent(withName: "filtered with tag",
                                           customAttributes: ["numberOfFilteredTags" : selectedTags.count])
                }
                
            }.disposed(by: disposeBag)
    }
    
    //MARK: - Empty State
    
    @IBOutlet weak var emptyStateImage: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateSubtitleLabel: UILabel!
    @IBOutlet weak var emptyStateOrLabel: UILabel!
    @IBOutlet weak var importFromRemindersButton: UIButton!
    
    fileprivate func showEmptyState(_ bool: Bool) {
        emptyStateSubtitleLabel.isHidden = !bool
        emptyStateTitleLabel.isHidden = !bool
        emptyStateImage.isHidden = !bool
        
        if bool, viewModel.delegate!.shouldShowImportFromRemindersOption() {
            emptyStateOrLabel.isHidden = false
            importFromRemindersButton.isHidden = false
        } else {
            emptyStateOrLabel.isHidden = true
            importFromRemindersButton.isHidden = true
        }
    }
    
    @IBAction func didClickImportFromRemindersButton(_ sender: Any) {
        viewModel.delegate?.importFromReminders()
    }
    
    fileprivate func configureEmptyState() {
        emptyStateTitleLabel.font = UIFont.font(sized: 18, weight: .bold, with: .title2)
        emptyStateSubtitleLabel.font = UIFont.font(sized: 14, weight: .light, with: .title3)
        emptyStateOrLabel.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        importFromRemindersButton.titleLabel?.font = UIFont.font(sized: 14, weight: .light, with: .caption2)
        importFromRemindersButton.titleLabel?.numberOfLines = 1
        
        emptyStateTitleLabel.text = viewModel.emptyStateTitleText
        emptyStateSubtitleLabel.text = viewModel.emptyStateSubtitleText
        emptyStateOrLabel.text = viewModel.emptyStateOrText
        importFromRemindersButton.setTitle(viewModel.importFromRemindersText,
                                           for: .normal)
    }
    
    fileprivate func configureBigTitle() {
        bigTitle.text = viewModel.bigTitleText
        maskLabel.text = viewModel.bigTitleText
        
        bigTitle.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        maskLabel.font = UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow)
        
        titleGradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor] //bigTitleColors
    }
    
    var bigTitleColors: [CGColor] {
        return viewModel.selectedTags.isEmpty
            ? [UIColor.black.cgColor, UIColor.black.cgColor]
            : TagModel.tagColors[ Int(viewModel.selectedTags.first!.colorIndex) ]
    }
    
    @IBAction func didTapBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel.unSelectBigTitle(tag: tag)
            
            Answers.logCustomEvent(withName: "unselected tag on screen title")
        }
    }
    
    @IBAction func didLongpressBigTitle(_ sender: Any) {
        if let tag = viewModel.selectedTags.first {
            tagCollectionViewController.presentActionSheet(for: tag)
            Answers.logCustomEvent(withName: "longpressed tag")
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
