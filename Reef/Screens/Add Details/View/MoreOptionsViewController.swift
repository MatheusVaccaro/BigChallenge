//
//  MoreOptionsViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class AddDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: AddDetailsProtocol!
    
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
    
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 6.3
        
        view.layer.cornerRadius = 6.3
        view.layer.shadowRadius = 6.3
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.masksToBounds = false
        view.layer.shadowColor = CGColor.shadowColor
        view.layer.shadowOpacity = 0.3

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        tableViewHeight.constant = tableView.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: reload only cells that have been edited
        tableView.reloadData()
    }
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "IconCell",
                                 bundle: nil),
                           forCellReuseIdentifier: IconTableViewCell.reuseIdentifier!)
    }
    
    override var accessibilityElementsHidden: Bool {
        didSet {
            tableView.accessibilityElementsHidden = accessibilityElementsHidden
        }
    }
}

// MARK: - UITableViewDataSourceDataSource
extension AddDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.reuseIdentifier!,
                                                 for: indexPath) as! IconTableViewCell
        
        cell.viewModel = viewModel.viewModelForCell(at: indexPath.row)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.shouldPresentView(at: indexPath.row)
    }
}

// MARK: - StoryboardInstantiable
extension AddDetailsViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "MoreOptions"
    }
    
    static var viewControllerID: String {
        return "MoreOptionsViewController"
    }
}
