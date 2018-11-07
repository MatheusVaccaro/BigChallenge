//
//  ThemeSelectViewController.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class ThemeSelectViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        view.backgroundColor = ReefColors.background
    }
    
    func configureTableView() {
        tableView.register(UINib(nibName: "ThemeCell", bundle: nil),
                           forCellReuseIdentifier: ThemeTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 114
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
    }
}

extension ThemeSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThemeTableViewCell.identifier,
                                                    for: indexPath) as! ThemeTableViewCell
        
        let theme: Theme.Type = indexPath.row == 0
            ? Classic.self
            : Dark.self
        
        cell.viewModel = ThemeTableViewModel(theme: theme)
        
        return cell
    }
}

extension ThemeSelectViewController: UITableViewDelegate {
    
}

extension ThemeSelectViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "ThemeTableView"
    }
    
    static var storyboardIdentifier: String {
        return "ThemeSelection"
    }
}
