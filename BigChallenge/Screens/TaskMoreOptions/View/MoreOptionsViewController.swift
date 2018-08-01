//
//  MoreOptionsViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class MoreOptionsViewController: UIViewController, TaskFramePresentable {
    
    // MARK: - Properties
    
    var viewModel: MoreOptionsViewModelProtocol?
    
    private var locationCellIsConfigured: Bool = false
    private var timeCellIsConfigured: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - MoreOptionsViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - TaskFramePresentable
    
    func didTapCancelButton(_ sender: UIButton) {
        print("didTapCancelButton")
    }
    
    func didTapMoreOptionsButton(_ sender: UIButton) {
        print("didTapMoreOptionsButton")
    }
    
    func didTapSaveButton(_ sender: UIButton) {
        print("didTapSaveButton")
    }
    
    // MARK: - Functions
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
    }

}

// MARK: - UITableViewDataSourceDataSource

extension MoreOptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreOptionsTableViewCell",
                                                       for: indexPath) as? MoreOptionsTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel: MoreOptionsTableViewCellViewModelProtocol
        if indexPath.row == 0 {
            cellViewModel = viewModel.locationViewModel()
        } else if indexPath.row == 1 {
            cellViewModel = viewModel.timeViewModel()
        } else {
            return UITableViewCell()
        }
        
        cell.configure(with: cellViewModel)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension MoreOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        let row = indexPath.row
        
        if row == 0 {
            if viewModel.isShowingLocationCell {
                viewModel.collapseLocationCell()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                viewModel.showLocationCell()
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }

        if row == 1 {
            if viewModel.isShowingTimeCell {
                viewModel.collapseTimeCell()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                viewModel.showTimeCell()
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
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
