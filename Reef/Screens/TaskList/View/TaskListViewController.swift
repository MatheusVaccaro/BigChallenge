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
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = UIColor.clear
        
        // config tableView to autolayout constraints to resize the tableCells height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TaskCell", bundle: nil),
                           forCellReuseIdentifier: TaskTableViewCell.identifier)
        
        tableView.estimatedRowHeight = 66
        tableView.estimatedSectionHeaderHeight = 50
        tableView.contentInset.top = 20
     
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.UIDelegate = self
        UNUserNotificationCenter.current().delegate = self
        print("+++ INIT TaskListViewController")
    }
    
    deinit {
        print("--- DEINIT TaskListViewController")
    }
    
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
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = view.frame
        
        let headerLabel = UILabel()
        headerLabel.text = viewModel.title(forHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        headerLabel.frame.origin.x += 10
        headerLabel.frame.origin.y =
            self.tableView(tableView, heightForHeaderInSection: section) - headerLabel.bounds.height - 5
        
        if viewModel.isCompleted(section) {
            let tapGesture =
                UITapGestureRecognizer(target: self, action: #selector(toggleCollapseInCompleteSection))
            headerView.addGestureRecognizer(tapGesture)
            
            let headerLabel = UILabel()
            headerLabel.text = viewModel.showHideHeader
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
            
            headerLabel.frame.origin.x =
                view.frame.width - headerLabel.bounds.width - 8
            headerLabel.frame.origin.y =
                self.tableView(tableView, heightForHeaderInSection: section) - headerLabel.bounds.height - 5
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
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = toggleCompleteAction(forRowAt: indexPath)
        
        let actions = [completeAction]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(forRowAt: indexPath)
        
        let actions = [delete]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func toggleCompleteAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action: UIContextualAction,
                                            view: UIView,
                                            completion: (Bool) -> Void) in
                                            
            self.viewModel.toggleComplete(taskAt: indexPath)
            completion(true)
        }
        
        let task = viewModel.task(for: indexPath)
        
        action.backgroundColor = task.isCompleted
            ? UIColor.Cell.uncompleteYellow
            : UIColor.Cell.completeGreen
        
        action.image = task.isCompleted
            ? UIImage(named: "uncomplete")
            : UIImage(named: "complete")
        
        return action
    }
    
    func deleteAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive,
                                        title: nil) { (action: UIContextualAction,
                                            view: UIView,
                                            completion: (Bool) -> Void) in
                                            view.backgroundColor = UIColor.Cell.deleteRed
                                            
                                            self.viewModel.delete(taskAt: indexPath)
                                            
                                            completion(true)
        }
        action.image = UIImage.init(named: "trash")
        return action
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
