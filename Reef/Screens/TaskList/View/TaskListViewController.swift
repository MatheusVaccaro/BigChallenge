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
import ReefTableViewCell

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
        tableView.register(UINib(nibName: "TaskCell",
                                 bundle: Bundle(identifier: "com.Wide.ReefTableViewCell")),
                           forCellReuseIdentifier: TaskTableViewCell.identifier)
        
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
        if viewModel.isCard(indexPath.section) {
            cell.layout(with: .card)
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
        
        subscribeToDragging(in: self.tableView)
        
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
    fileprivate var lightImpactOcurred: Bool = true
    fileprivate var heavyImpactOcurred: Bool = false
    fileprivate var mediumImpactOcurred: Bool = false
    
    func subscribeToDragging(in tableView: UITableView) {
        tableView.rx.willBeginDragging.subscribe { _ in
            self.resetFeedback()
            self.prepareFeedback()
        }.disposed(by: disposeBag)
        
        tableView.rx.didScroll.subscribe { _ in
            self.triggerLightImpactIfNeeded()
            self.triggerMediumImpactIfNeeded()
            self.triggerHeavyImpactIfNeeded()
            }.disposed(by: disposeBag)
        
        tableView.rx.didEndDragging.subscribe { _ in
            self.feedbackGenerator = nil
            if tableView.shouldAddNewTask {
                self.viewModel.shouldGoToAddTask()
            }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func prepareFeedback() {
        print("preparing feedback")
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
    
    fileprivate func resetFeedback() {
        lightImpactOcurred = true
        mediumImpactOcurred = false
        heavyImpactOcurred = false
    }
    
    fileprivate func triggerLightImpactIfNeeded() {
        if shouldTriggerLightImpact {
            print( "triggered light impact" )
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator?.impactOccurred()
            resetFeedback() // reach end of feedback cycle
        }
        
    }
    
    fileprivate func triggerMediumImpactIfNeeded() {
        if shouldTriggerMediumImpact {
            print( "triggered medium impact" )
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator?.impactOccurred()
            mediumImpactOcurred = true
        }
        
    }
    
    fileprivate func triggerHeavyImpactIfNeeded() {
        if shouldTriggerHeavyImpact {
            print( "triggered heavy impact" )
            feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator?.impactOccurred()
            heavyImpactOcurred = true
            lightImpactOcurred = false // prepare back drag light impact
        }
    }
    
    fileprivate var shouldTriggerLightImpact: Bool {
        guard !lightImpactOcurred else { return false }
        return tableView.contentOffset.y > -50.0
    }
    
    fileprivate var shouldTriggerMediumImpact: Bool {
        guard !mediumImpactOcurred else { return false }
        return tableView.contentOffset.y < -50.0
    }
    
    fileprivate var shouldTriggerHeavyImpact: Bool {
        guard !heavyImpactOcurred else { return false }
        return tableView.shouldAddNewTask
    }
}

fileprivate extension UITableView {
    var shouldAddNewTask: Bool {
        return contentOffset.y < -80.0
    }
}

extension TaskListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.task(for: indexPath)
        viewModel.shouldEditTask.onNext(task)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.5 + ( viewModel.hasHeaderIn(section) ? heightOfHeaderTag! : 0 )
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.isCard(section) ? 46 : 23
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: view.frame)

        if viewModel.isCard(section) {
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
            for tag in viewModel.tags(forHeadersIn: section) {
                let header = textHeaderView(with: tag.title!, colored: tag.color)
                header.frame.origin.x += xPosition
                headerView.addSubview(header)
                xPosition += header.frame.width + 5
                
            }
            return headerView
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard viewModel.isCard(section) else { return nil }
        
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
