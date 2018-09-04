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
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        viewModel = TodayViewModel()
        viewModel.delegate = self
        configureTableView()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: "TaskCell", bundle: Bundle(identifier: "com.Wide.ReefTableViewCell")),
                           forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfTasks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier,
                                                       for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let cellViewModel = TaskCellViewModel(task: viewModel.task(for: indexPath.row))
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
    }
    
    func reloadedTasks() {
        tableView.reloadData()
    }
}
