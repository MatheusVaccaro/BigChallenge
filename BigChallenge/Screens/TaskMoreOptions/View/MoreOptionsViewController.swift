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
    var locationCellContent: UIViewController?
    var timeCellContent: UIViewController?
    
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
        
        let row = indexPath.row
        let cellViewModel: MoreOptionsTableViewCellViewModelProtocol
        if row == 0 && !locationCellIsConfigured {
            cellViewModel = viewModel.locationViewModel()
            cell.configure(with: cellViewModel)
            locationCellIsConfigured = true
        } else if row == 1 && !timeCellIsConfigured {
            cellViewModel = viewModel.timeViewModel()
            cell.configure(with: cellViewModel)
            timeCellIsConfigured = true
        } else if row == 1 && viewModel.isShowingLocationCell {
            //configure location vc
            guard let locationCellContent = locationCellContent else { return UITableViewCell() }
            locationCellContent.view.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(locationCellContent.view)
            
            NSLayoutConstraint.activate([
                locationCellContent.view
                    .leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                locationCellContent.view
                    .trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                locationCellContent.view
                    .topAnchor.constraint(equalTo: cell.topAnchor),
                locationCellContent.view
                    .bottomAnchor.constraint(equalTo: cell.bottomAnchor)
                ])
            
        } else if (row == 2 && viewModel.isShowingTimeCell) || (row == 3 && viewModel.isShowingTimeCell) {
            //configure time vc
            guard let timeCellContent = timeCellContent else { return UITableViewCell() }
            timeCellContent.view.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(timeCellContent.view)
            
            NSLayoutConstraint.activate([
                timeCellContent.view
                    .leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                timeCellContent.view
                    .trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                timeCellContent.view
                    .topAnchor.constraint(equalTo: cell.topAnchor),
                timeCellContent.view
                    .bottomAnchor.constraint(equalTo: cell.bottomAnchor)
                ])
            
        } else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel else { return 82 }
        
        let row = indexPath.row
        
        if row == 1 && viewModel.isShowingLocationCell {
            return locationCellContent?.view.frame.height ?? 82
            
        } else if (row == 2 && viewModel.isShowingTimeCell) || (row == 3 && viewModel.isShowingTimeCell) {
            return timeCellContent?.view.frame.height ?? 82
        } else {
            return 82
        }
    }
    
}

// MARK: - UITableViewDelegate

extension MoreOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        let row = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        let cellIndex = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        if row == 0 && cell is MoreOptionsTableViewCell {
            if viewModel.isShowingLocationCell {
                viewModel.collapseLocationCell()
                tableView.deleteRows(at: [cellIndex], with: .top)
            } else {
                viewModel.showLocationCell()
                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        if (row == 1 && cell is MoreOptionsTableViewCell) || (row == 2 && cell is MoreOptionsTableViewCell) {
            if viewModel.isShowingTimeCell {
                viewModel.collapseTimeCell()
                tableView.deleteRows(at: [cellIndex], with: .top)
            } else {
                viewModel.showTimeCell()
                tableView.insertRows(at: [cellIndex], with: .automatic)
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
