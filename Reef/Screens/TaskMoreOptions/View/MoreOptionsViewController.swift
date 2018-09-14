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
    func shouldPresentViewForDateInput()
}

class MoreOptionsViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: MoreOptionsViewModel!
    weak var delegate: MoreOptionsDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var contentSize: CGFloat {
        return tableViewHeight.constant
    }
    
    // MARK: - MoreOptionsViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillLayoutSubviews() {
        tableViewHeight.constant = tableView.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //TODO: reload only cells that have been edited
        tableView.reloadData()
    }
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "IconCell",
                                 bundle: nil),
                           forCellReuseIdentifier: IconTableViewCell.reuseIdentifier!)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.reuseIdentifier!,
                                                 for: indexPath) as! IconTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.viewModel = viewModel.locationInputViewModel
        default:
            cell.viewModel = viewModel.dateInputViewModel
            viewWillLayoutSubviews()
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
        case 1:
            delegate?.shouldPresentViewForDateInput()
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
