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
    
    public override func viewDidAppear(_ animated: Bool) {
        resetFeedback()
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
        
        tableView.rx.willBeginDragging.subscribe { _ in
            self.resetFeedback()
            self.prepareFeedback()
        }.disposed(by: disposeBag)
        
        tableView.rx.didScroll.subscribe { _ in
            if self.shouldTriggerMediumImpact(self.tableView) {
                self.triggerImpact(.medium)
            } else if !self.heavyImpactOcurred, self.shouldAddNewTask(self.tableView) {
                self.triggerImpact(.heavy)
            } else if self.shouldTriggerMediumImpact(self.tableView) {
                self.triggerImpact(.medium)
            } else if !self.heavyImpactOcurred, self.shouldShowCompletedTasks(self.tableView) {
                self.triggerImpact(.heavy)
            }
            
        }.disposed(by: disposeBag)

        tableView.rx.didEndDragging.subscribe { _ in
            if self.shouldAddNewTask(self.tableView) {
                self.viewModel.shouldGoToAddTask()
             } else if self.shouldShowCompletedTasks(self.tableView) {
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
            textHeaderView(with: viewModel.section2HeaderTitle,
                           colored: UIColor.purple)
        
        heightOfHeaderTag = alsoTaggedHeader.bounds.size.height
    }
    
    // MARK: - Haptics
    fileprivate var feedbackGenerator: UIImpactFeedbackGenerator?
    fileprivate var lightImpactOcurred: Bool = false
    fileprivate var heavyImpactOcurred: Bool = false
    fileprivate var mediumImpactOcurred: Bool = false
    
    fileprivate func prepareFeedback() {
        print("preparing feedback")
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
    
    fileprivate func triggerImpact(_ style: UIImpactFeedbackStyle) {
        print("triggered \(style.rawValue) impact")
        self.feedbackGenerator?.impactOccurred()
        switch style {
        case .light:
            lightImpactOcurred = true
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator?.prepare()
        case .medium:
            mediumImpactOcurred = true
            feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator?.prepare()
        case .heavy:
            heavyImpactOcurred = true
        }
    }
    
    fileprivate func resetFeedback() {
        feedbackGenerator = nil
        lightImpactOcurred = false
        mediumImpactOcurred = false
        heavyImpactOcurred = false
    }
    
    fileprivate func shouldAddNewTask(_ tableView: UITableView) -> Bool {
        return self.tableView.contentOffset.y < -80.0
    }
    
    fileprivate func shouldShowCompletedTasks(_ tableView: UITableView) -> Bool {
        return tableView.contentSize.height < tableView.bounds.height
            ? tableView.contentOffset.y > 80
            : tableView.contentOffset.y + tableView.bounds.height > tableView.contentSize.height + 80
    }
    
    fileprivate func shouldTriggerMediumImpact(_ tableView: UITableView) -> Bool {
        guard !mediumImpactOcurred else { return false }
        if self.tableView.contentOffset.y < -50.0 {
            return true
        } else {
            return tableView.contentSize.height < tableView.bounds.height + 50
                ? tableView.contentOffset.y > 50
                : tableView.contentOffset.y + tableView.bounds.height > tableView.contentSize.height + 50
        }
    }
}

extension TaskListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task =
            indexPath.section == 0 && tableView.numberOfSections == 2
                ? viewModel.mainTasks[indexPath.row]
                : viewModel.tasksToShow[indexPath.row]
        viewModel.shouldEditTask.onNext(task)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !(viewModel.mainTasks.isEmpty) else { return 0 }
        let additionalHeight = (section == 0 && !viewModel.selectedTags.isEmpty)
            ? 0
            : heightOfHeaderTag!
        
        return 10.5 + additionalHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.mainTasks.isEmpty && viewModel.selectedTags.isEmpty ? 0 : 46
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: view.frame)

        if section == 0 {
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
        } else { // also tagged section
            guard !viewModel.secondaryTasks.isEmpty && viewModel.selectedTags.isEmpty else { return headerView }
            headerView.addSubview(alsoTaggedHeader)
            return headerView
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !viewModel.mainTasks.isEmpty && section == 0 else { return nil }
        
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
