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

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
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
        
    }
    
}
