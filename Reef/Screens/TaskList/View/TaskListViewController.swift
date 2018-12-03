//
//  TaskListViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import ReefKit
import UserNotifications

public class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: TaskListViewModel!
    private let disposeBag = DisposeBag()
    fileprivate var heightOfHeaderTag: CGFloat!
    private var alsoTaggedHeader: UIView!
    
    // MARK: - Swipe Control
    
    private var isCleaningQueues: Bool = false
    
    private var swipeCompletedQueue: [TaskTableViewCell : SwipeDirection] = [:] {
        didSet {
            completeSwipesIfPossible()
            print("completed queue:\n\(swipeCompletedQueue)")
        }
    }
    
    private var swipeUpdateQueue: [TaskTableViewCell : SwipeDirection] = [:] {
        didSet {
            completeSwipesIfPossible()
            print("update queue:\n\(swipeUpdateQueue)")
        }
    }
    
    private func completeSwipesIfPossible() {
        guard !isCleaningQueues else { return }
        guard swipeCompletedQueue.count == swipeUpdateQueue.count else { return }
        swipeCompletedQueue.forEach {
            guard swipeUpdateQueue.keys.contains($0.key) && swipeUpdateQueue[$0.key] == $0.value else { return }
        }
        swipeCompletedQueue.forEach {
            guard let index = tableView.indexPath(for: $0.key) else { return }
            switch $0.value {
            case .leftToRight:
                viewModel.toggleComplete(taskAt: index)
            case .rightToLeft:
                viewModel.delete(taskAt: index)
            default:
                return
            }
        }
        isCleaningQueues = true
        swipeCompletedQueue.removeAll()
        swipeUpdateQueue.removeAll()
        isCleaningQueues = false
    }

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = UIColor.clear
        
        // config tableView to autolayout constraints to resize the tableCells height
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TaskCell", bundle: nil),
                           forCellReuseIdentifier: TaskTableViewCell.identifier)
        
        tableView.estimatedRowHeight = 66
        tableView.estimatedSectionHeaderHeight = 25
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    
        tableView.contentInset.top = 20
     
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.UIDelegate = self
        UNUserNotificationCenter.current().delegate = self
        
        #if DEBUG
        print("+++ INIT TaskListViewController")
        #endif
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT TaskListViewController")
    }
    #endif
    
    fileprivate func textHeaderView(with text: String) -> UIView {
        
        let label = UILabel()
        label.font = UIFont.font(sized: 13, weight: .regular, with: .footnote)
        label.textColor = UIColor.white
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 8, y: 3)
        
        let frame = CGRect(x: 8, y: 0, width: 150, height: 21)
        let headerView = UIView(frame: frame)
        headerView.addSubview(label)
        headerView.frame.size = CGSize(width: label.frame.size.width + 16, height: label.frame.size.height + 6)
        
        return headerView
    }
    
    public override func viewDidLayoutSubviews() {
        alsoTaggedHeader = textHeaderView(with: viewModel.otherHeader)
        heightOfHeaderTag = alsoTaggedHeader.bounds.size.height
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
}

extension TaskListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.task(for: indexPath)
        viewModel.shouldGoToEdit(task)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = view.frame
        
        let headerLabel = UILabel()
        headerLabel.font = UIFont.font(sized: 14, weight: .light, with: .headline)
        headerLabel.textAlignment = .right
        
        var imageView: UIImageView?
        
        if viewModel.isCompleted(section) {
            let tapGesture =
                UITapGestureRecognizer(target: self, action: #selector(toggleCollapseInCompleteSection))
            headerView.addGestureRecognizer(tapGesture)
            
            headerLabel.text = viewModel.showHideHeader
            headerLabel.textColor = ReefColors.theme.cellTagLabel
            
        } else {
            if let image = viewModel.image(forHeaderIn: section) {
                imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
                imageView?.tintColor = ReefColors.theme.sectionHeaderIcon
            }
            
            headerLabel.text = viewModel.title(forHeaderInSection: section)
            headerLabel.textColor = ReefColors.theme.sectionHeaderLabel
            
        }
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.sizeToFit()
        headerLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16),
            headerLabel.topAnchor.constraint(greaterThanOrEqualTo: headerView.topAnchor),
            headerLabel.leftAnchor.constraint(greaterThanOrEqualTo: headerView.leftAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: headerLabel.frame.height)
            ])
        
        if let imageView = imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
                imageView.rightAnchor.constraint(equalTo: headerLabel.leftAnchor, constant: -3),
                imageView.leftAnchor.constraint(greaterThanOrEqualTo: headerView.leftAnchor, constant: 16),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                imageView.heightAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 0.8)
                ])
        }
        
        return headerView
    }
    
    @objc func toggleCollapseInCompleteSection() {
        let completedSection = viewModel.taskListData.count-1
        
        viewModel.isCompleteSectionCollapsed.toggle()
        tableView.reloadSectionIndexTitles()
        
        if UIAccessibility.isReduceMotionEnabled {
            tableView.reloadSections([completedSection], with: .fade)
        } else {
            tableView.reloadSections([completedSection], with: .automatic)
        }
        if !viewModel.isCompleteSectionCollapsed {
            tableView.scrollToRow(at: IndexPath(row: 0, section: completedSection), at: .middle, animated: true)
        }
    }
    
}

extension TaskListViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: TaskTableViewCell.identifier,
                for: indexPath) as? TaskTableViewCell else {
                    return UITableViewCell()
        }
        
        let taskCellViewModel = self.viewModel.taskCellViewModel(for: indexPath)
        
        cell.configure(with: taskCellViewModel)
        cell.swipeDelegate = self
        
//        if !viewModel.selectedTags.contains { $0.requiresAuthentication }, taskCellViewModel.taskIsPrivate {
//            let blurEffect = UIBlurEffect(style: .regular)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            blurView.frame = cell.contentView.bounds
//            cell.contentView.addSubview(blurView)
//        } TODO: review (this code blurs private task cells)
        
        return cell
    }
}

extension TaskListViewController: taskListViewModelUIDelegate {
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didUpdateAt indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didInsertAt indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didDeleteRowsAt indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didDeleteSection section: Int) {
        tableView.deleteSections([section], with: .automatic)
    }
    
    func taskListViewModelDidUpdate(_ taskListViewModel: TaskListViewModel) {
        tableView.reloadData()
    }
}

extension TaskListViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        guard let taskID = userInfo["TASK_ID"] as? String else {
            completionHandler()
            return
        }
        
        guard let taskUUID = UUID(uuidString: taskID) else { return }
        
        switch response.actionIdentifier {
        case "COMPLETE":
            viewModel.completeTask(taskID: taskUUID)
            
        case "POSTPONE_ONE_HOUR":
            NotificationManager.postponeOneHour(request: response.notification.request)
            
        case "POSTPONE_ONE_DAY":
            NotificationManager.postponeOneDay(request: response.notification.request)
            
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - StoryboardInstantiable
extension TaskListViewController: StoryboardInstantiable {
    
    static var viewControllerID: String {
        return "TaskListViewController"
    }
    
    static var storyboardIdentifier: String {
        return "TaskList"
    }
}

extension TaskListViewController: TaskTableViewCellSwipeDelegate {
    
    public func didStartSwipeFromLeftToRight(in cell: TaskTableViewCell) {
        swipeUpdateQueue[cell] = .leftToRight
    }
    
    public func didCancelSwipeFromLeftToRight(in cell: TaskTableViewCell) {
        swipeUpdateQueue[cell] = nil
    }
    
    public func didFinishSwipeFromLeftToRight(in cell: TaskTableViewCell) {
        swipeCompletedQueue[cell] = .leftToRight
    }
    
    public func didStartSwipeFromRightToLeft(in cell: TaskTableViewCell) {
        swipeUpdateQueue[cell] = .rightToLeft
    }
    
    public func didCancelSwipeFromRightToLeft(in cell: TaskTableViewCell) {
        swipeUpdateQueue[cell] = nil
    }
    
    public func didFinishSwipeFromRightToLeft(in cell: TaskTableViewCell) {
        swipeCompletedQueue[cell] = .rightToLeft
    }
}
