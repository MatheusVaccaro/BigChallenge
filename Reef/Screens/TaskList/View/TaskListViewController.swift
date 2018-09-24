//
//  TaskListViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReefKit
import UserNotifications

struct SectionedTaskModel {
    var items: [Task]
}

extension SectionedTaskModel: SectionModelType {
    init(original: SectionedTaskModel, items: [Task]) {
        self = original
        self.items = items
    }
    
    typealias Item = Task
}

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
        
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionHeaderHeight = 18.5
        tableView.estimatedSectionFooterHeight = 46
        tableView.contentInset.top = 40
                
        bindTableView()
        UNUserNotificationCenter.current().delegate = self
        print("+++ INIT TaskListViewController")
    }
    
    deinit {
        print("--- DEINIT TaskListViewController")
    }
    
    private func bindTableView() {
        let dataSource = createDataSource()
        
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // divide tasks in main and secondary sections
        // filter empty sections
        viewModel.tasksObservable
            .map {
                return $0
                    .map { SectionedTaskModel(items: $0) }
                    .filter { !$0.items.isEmpty }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    fileprivate func layout(cell: TaskTableViewCell, with indexPath: IndexPath) {
        if viewModel.isCardSection(indexPath.section) {
            cell.layout(with: .card)
        } else {
            cell.layout(with: .none)
        }
    }
    
    fileprivate func createDataSource() -> RxTableViewSectionedReloadDataSource<SectionedTaskModel> {
        let ans = RxTableViewSectionedReloadDataSource<SectionedTaskModel>(
            configureCell: {(_, table, indexPath, task) in
                guard let cell =
                    table.dequeueReusableCell(
                        withIdentifier: TaskTableViewCell.identifier,
                        for: indexPath) as? TaskTableViewCell else {
                    return UITableViewCell()
                }
                
                let taskCellViewModel = self.viewModel.taskCellViewModel(for: task)
                
                taskCellViewModel.taskObservable.subscribe {
                    if let task = $0.element {
                        if task.isCompleted {
                            self.viewModel.taskCompleted.onNext(task)
                        }
                    }
                    }.disposed(by: self.disposeBag)
                
                cell.configure(with: taskCellViewModel)
                cell.delegate = self
                
                self.layout(cell: cell, with: indexPath)
                
                return cell
            })
        
        return ans
    }
    
    fileprivate func textHeaderView(with text: String, colored color: UIColor) -> UIView {
        
        let label = UILabel()
        label.font = UIFont.font(sized: 13, weight: .regular, with: .footnote)
        label.textColor = UIColor.white
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 8, y: 3)
        
        let frame = CGRect(x: 8, y: 0, width: 150, height: 21)
        let headerView = UIView(frame: frame)
        headerView.backgroundColor = color
        headerView.layer.cornerRadius = 6.3
        headerView.addSubview(label)
        headerView.frame.size = CGSize(width: label.frame.size.width + 16, height: label.frame.size.height + 6)
        
        return headerView
    }
    
    public override func viewDidLayoutSubviews() {
        alsoTaggedHeader =
            textHeaderView(with: viewModel.section2HeaderTitle,
                           colored: UIColor.purple)
        
        heightOfHeaderTag = alsoTaggedHeader.bounds.size.height
    }
}

extension TaskListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.task(for: indexPath)
        viewModel.shouldGoToEdit(task)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.5 + ( viewModel.hasHeaderInSection(section) ? heightOfHeaderTag! : 0 )
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.isCardSection(section) ? 46 : 23
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: view.frame)

        if viewModel.isCardSection(section) {
            let cardView = UIView(frame: headerView.bounds)
            var textHeader = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            if viewModel.selectedTags.isEmpty {
                textHeader = textHeaderView(with: viewModel.recommendedHeaderTitle,
                                            colored: UIColor.darkGray)
            }
            
            let headerHeight =
                tableView.delegate!.tableView!(tableView, heightForHeaderInSection: section)
            
            cardView.frame.size.height = headerHeight - (textHeader.bounds.height*0.5)
            cardView.frame.origin.y = headerHeight - cardView.frame.size.height
            cardView.layer.cornerRadius = 6.3
            cardView.backgroundColor = UIColor.white
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerView.addSubview(cardView)
            
            textHeader.frame.origin.y = cardView.frame.origin.y - (textHeader.bounds.height*0.5)
            headerView.addSubview(textHeader)
            
            return headerView
        } else {
            var xPosition: CGFloat = 0
            for tag in viewModel.tags(forHeadersInSection: section) {
                let header = textHeaderView(with: tag.title!, colored: tag.color)
                header.frame.origin.x += xPosition
                headerView.addSubview(header)
                xPosition += header.frame.width + 5
                
            }
            return headerView
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard viewModel.isCardSection(section) else { return nil }
        
        let footerView = UIView(frame: view.bounds)
        let cardView = UIView(frame: footerView.bounds)
        
        cardView.frame.origin.y -= 1
        cardView.frame.size.height = 14
        cardView.layer.cornerRadius = 6.3
        cardView.backgroundColor = UIColor.white
        cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        footerView.addSubview(cardView)
        
        return footerView
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

extension TaskListViewController: TaskCellDelegate {
    public func edit(_ cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let task = viewModel.task(for: indexPath)
        
        viewModel.shouldGoToEdit(task)
    }
    
    public func delete(_ cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let task = viewModel.task(for: indexPath)
        viewModel.delete(task)
    }
    
    
    public func shouldUpdateSize(of cell: TaskTableViewCell) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
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
