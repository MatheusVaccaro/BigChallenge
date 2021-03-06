//
//  AddDetailsViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit


protocol AddTagDetailsDelegate: class {
    func addTagDetailsDidBecomeFirstResponder()
}

class AddDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: AddDetailsProtocol!
    weak var delegate: AddTagDetailsDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    var contentHeight: CGFloat! {
//        guard tableView.contentSize.height != 0 else {
//            return tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
//        }
        return tableView.contentSize.height
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tableView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UISwipeGestureRecognizer) {
        let tapLocation = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: tapLocation) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
        }
        delegate?.addTagDetailsDidBecomeFirstResponder()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.addTagDetailsDidBecomeFirstResponder()
        super.touchesMoved(touches, with: event)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        
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
        if let cell = tableView.cellForRow(at: indexPath) as? IconTableViewCell {
            if cell.viewModel.isSwitchCell {
                cell.switchToggled(cell.cellSwitch)
            } else {
                viewModel.shouldPresentView(at: indexPath.row)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.addTagDetailsDidBecomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - StoryboardInstantiable
extension AddDetailsViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "Details"
    }
    
    static var viewControllerID: String {
        return "DetailsViewController"
    }
}
