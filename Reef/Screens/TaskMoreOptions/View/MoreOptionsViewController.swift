//
//  MoreOptionsViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class MoreOptionsViewController: UIViewController, CreationFramePresentable {
    
    // MARK: - Properties
    
    var viewModel: MoreOptionsViewModelProtocol?
    var locationCellContent: UIViewController?
    var timeCellContent: UIViewController?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - MoreOptionsViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - TaskFramePresentable
    
    func didTapMoreOptionsButton(_ sender: UIButton) {
        print("didTapMoreOptionsButton")
    }
    
    // MARK: - Functions
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.allowsSelection = false
    }
    
    @objc fileprivate func toggleLocationCell() {
        guard let viewModel = viewModel else { return }
        if viewModel.isShowingLocationCell {
            viewModel.collapseLocationCell()
            tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        } else {
            viewModel.showLocationCell()
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    @objc fileprivate func toggleTimeCell() {
        guard let viewModel = viewModel else { return }
        if viewModel.isShowingTimeCell {
            viewModel.collapseTimeCell()
            tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .top)
        } else {
            viewModel.showTimeCell()
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
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
        let cell = UITableViewCell()
        let section = indexPath.section
        
        if let locationCellContent = locationCellContent, section == 0 {
            locationCellContent.view.frame.size.height = 290
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
        }
        
        if let timeCellContent = timeCellContent, section == 1 {
            cell.addSubview(timeCellContent.view)
            timeCellContent.view.translatesAutoresizingMaskIntoConstraints = false
            
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let defaultValue: CGFloat = 50
        if section == 0 {
            return locationCellContent?.view.frame.height ?? defaultValue
        }
        if section == 1 {
            return timeCellContent?.view.frame.height ?? defaultValue
        }
        return defaultValue
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = viewModel else { return nil }
        let headerViewController = HeaderViewController.instantiate()
        if section == 0 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleLocationCell))
            headerViewController.view.addGestureRecognizer(gestureRecognizer)
            headerViewController.configure(with: viewModel.locationViewModel())
            return headerViewController.view
        }
        if section == 1 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleTimeCell))
            headerViewController.view.addGestureRecognizer(gestureRecognizer)
            headerViewController.configure(with: viewModel.timeViewModel())
            return headerViewController.view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 82
    }
}

// MARK: - UITableViewDelegate

extension MoreOptionsViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let viewModel = viewModel else { return }
//
//        let row = indexPath.row
//        let cell = tableView.cellForRow(at: indexPath)
//        let cellIndex = IndexPath(row: indexPath.row + 1, section: indexPath.section)
//
//        if row == 0 && cell is MoreOptionsTableViewCell {
//            if viewModel.isShowingLocationCell {
//                viewModel.collapseLocationCell()
//                tableView.deleteRows(at: [cellIndex], with: .top)
//            } else {
//                viewModel.showLocationCell()
//                tableView.insertRows(at: [cellIndex], with: .automatic)
//            }
//        }
//
//        if (row == 1 && cell is MoreOptionsTableViewCell) || (row == 2 && cell is MoreOptionsTableViewCell) {
//            if viewModel.isShowingTimeCell {
//                viewModel.collapseTimeCell()
//                tableView.deleteRows(at: [cellIndex], with: .top)
//            } else {
//                viewModel.showTimeCell()
//                tableView.insertRows(at: [cellIndex], with: .automatic)
//            }
//        }
//    }
    
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
