//
//  MoreOptionsViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol MoreOptionsDelegate: class {
    func shouldPresentViewForLocationInput()
}

class MoreOptionsViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: MoreOptionsViewModel!
    weak var delegate: MoreOptionsDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - MoreOptionsViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "OptionCell",
                                 bundle: nil),
                           forCellReuseIdentifier: OptionTableViewCell.reuseIdentifier!)
    }
}

// MARK: - UITableViewDataSourceDataSource
extension MoreOptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.reuseIdentifier!,
                                                 for: indexPath) as! OptionTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.viewModel = viewModel.locationInputViewModel
        default:
            cell.viewModel = viewModel.dateInputViewModel
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MoreOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            delegate?.shouldPresentViewForLocationInput()
        default:
            print("present date screen")
        }
    }
}

// MARK: - StoryboardInstantiable
extension MoreOptionsViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "MoreOptions"
    }
    
    static var viewControllerID: String {
        return "MoreOptionsViewController"
    }
}
