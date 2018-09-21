//
//  TodayViewController.swift
//  ReefToday
//
//  Created by Bruno Fulber Wide on 26/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import NotificationCenter
import ReefTableViewCell
import RxSwift

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: TodayViewModel!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        viewModel = TodayViewModel()
        viewModel.delegate = self
        
        emptyStateLabel.font = UIFont.font(sized: 20, weight: .regular, with: .body)
        emptyStateLabel.text = viewModel.emptyStateText
        
        showLockedScreenStateIfNeeded()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.resetRecommendedTasks()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded
            ? CGSize(width: maxSize.width, height: 200)
            : maxSize
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: "TaskCell", bundle: nil),
                           forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    fileprivate func showEmptyStateIfNeeded() {
        tableView.isHidden = viewModel.shouldShowEmptyState
        emptyStateLabel.isHidden = !viewModel.shouldShowEmptyState
    }
    
    fileprivate func showExpandedOptionIfNeeded() {
        extensionContext?.widgetLargestAvailableDisplayMode = viewModel.numberOfTasks > 2
            ? .expanded
            : .compact
    }
    
    fileprivate func showLockedScreenStateIfNeeded() {
        
    }
    
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfTasks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier,
                                                       for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let cellViewModel = TodayTaskCellViewModel(task: viewModel.task(for: indexPath.row))
        cell.configure(with: cellViewModel)
        
        cellViewModel.taskObservable.subscribe { event in
            if let task = event.element {
                self.viewModel.completed(task)
            }
            }.disposed(by: disposeBag)
        
        return cell
    }
}

extension TodayViewController: TodayViewModelDelegate {
    func removedTasks(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        showEmptyStateIfNeeded()
        showExpandedOptionIfNeeded()
    }
    
    func reloadedTasks() {
        tableView.reloadData()
        showExpandedOptionIfNeeded()
        showEmptyStateIfNeeded()
    }
}
