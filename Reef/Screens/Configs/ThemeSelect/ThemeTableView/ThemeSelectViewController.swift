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
    var viewModel: ThemeSelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.tintColor = ReefColors.theme.largeTitle
        
        configureTableView()
        configureColors()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureColors()
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
    
    func configureColors() {
        view.backgroundColor = ReefColors.background
    }
}

extension ThemeSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThemeTableViewCell.identifier,
                                                    for: indexPath) as! ThemeTableViewCell
        
        cell.viewModel = viewModel.viewModelForCell(at: indexPath)
        
        return cell
    }
}

extension ThemeSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.data[indexPath.row]
        
        ReefColors.set(theme: item.theme)
        
        navigationController?
            .navigationBar
            .largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] = ReefColors.largeTitle
        
        for viewController in navigationController!.viewControllers {
            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()
            if let homescreen = viewController as? HomeScreenViewController {
                homescreen.reloadColors()
            }
        }
    }
}

extension ThemeSelectViewController: ThemeSelectionViewModelDelegate {
    func didLoadProducts() {
        tableView.reloadData()
    }
}

extension ThemeSelectViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "ThemeTableView"
    }
    
    static var storyboardIdentifier: String {
        return "ThemeSelection"
    }
}
