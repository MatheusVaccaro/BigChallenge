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
        tableView.backgroundColor = UIColor.clear
        
        // config tableView to autolayout constraints to resize the tableCells height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionHeaderHeight = 18.5
        tableView.estimatedSectionFooterHeight = 46
                
        bindTableView()
    }
    
    private func bindTableView() {
        let dataSource = createDataSource()
        
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.tasksObservable
            .map {
                return [SectionedTaskModel(items: $0.0), // divide tasks in main and secondary sections
                        SectionedTaskModel(items: $0.1)].filter { !$0.items.isEmpty } // filter empty sections
            }.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    fileprivate func layout(cell: TaskTableViewCell, with indexPath: IndexPath) {
        if indexPath.section == 0, !viewModel.mainTasks.isEmpty {
            cell.layout(with: .main)
        } else {
            cell.layout(with: .none)
        }
    }
    
    fileprivate func createDataSource() -> RxTableViewSectionedReloadDataSource<SectionedTaskModel> {
        let ans = RxTableViewSectionedReloadDataSource<SectionedTaskModel>(
            configureCell: {(dataSource, table, indexPath, task) in
                let cell =
                    table.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier,
                                              for: indexPath) as! TaskTableViewCell
                
                let taskCellViewModel = self.viewModel.taskCellViewModel(for: task)
                
                taskCellViewModel.taskObservable.subscribe {
                    if let task = $0.element {
                        self.viewModel.taskCompleted.onNext(task)
                    }
                    }.disposed(by: self.disposeBag)
                
                cell.configure(with: taskCellViewModel)
                cell.delegate = self
                
                self.layout(cell: cell, with: indexPath)
                
                return cell
            })

        tableView.rx.didEndDragging.subscribe { _ in
            if self.tableView.contentOffset.y < -100.0 {
                self.viewModel.shouldGoToAddTask()
             } else if self.viewModel.shouldShowCompletedTasks(self.tableView) {
                self.viewModel.showsCompletedTasks = !self.viewModel.showsCompletedTasks
            }
        }.disposed(by: disposeBag)
        
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
            textHeaderView(with: Strings.Task.ListScreen.section2HeaderTitle,
                           colored: UIColor.purple)
        
        heightOfHeaderTag = alsoTaggedHeader.bounds.size.height
    }
}

extension TaskListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !viewModel.mainTasks.isEmpty else { return 0 }
        return 10.5 + heightOfHeaderTag
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.mainTasks.isEmpty ? 0 : 46
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !viewModel.mainTasks.isEmpty else { return nil }
        
        let headerView = UIView(frame: view.frame)

        guard section == 0 else {
            guard !viewModel.secondaryTasks.isEmpty else { return nil }
            headerView.addSubview(alsoTaggedHeader)
            return headerView
        }
        
        let cardView = UIView(frame: headerView.bounds)
        
        cardView.frame.size.height = 8
        cardView.frame.origin.y = tableView.delegate!.tableView!(tableView, heightForHeaderInSection: section) - 8
        cardView.layer.cornerRadius = 6.3
        cardView.backgroundColor = UIColor.white
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        headerView.addSubview(cardView)

        if viewModel.selectedTags.isEmpty {
            headerView.addSubview(textHeaderView(with: Strings.Task.ListScreen.recommendedHeaderTitle,
                                                 colored: UIColor.darkGray))
        }
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !viewModel.mainTasks.isEmpty && section == 0 else { return nil }
        
        let footerView = UIView(frame: view.frame)
        
        let cardView = UIView(frame: footerView.bounds)
        
        cardView.frame.size.height = 8
        cardView.layer.cornerRadius = 6.3
        cardView.backgroundColor = UIColor.white
        cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        footerView.addSubview(cardView)
        
        return footerView
    }
}

extension TaskListViewController: TaskCellDelegate {
    func shouldUpdateSize(of cell: TaskTableViewCell) {
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
