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
        
        if let row = viewModel.data.firstIndex(where: { $0.theme == ReefColors.theme }) {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    func configureColors() {
        view.backgroundColor = ReefColors.background
    }
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: ReefColors.blurStyle)
        let blur = UIVisualEffectView(effect: blurEffect)
        
        blur.frame = view.bounds
        
        return blur
    }()
    
    private func applyBlur() {
        //only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled {
            blurView.tintColor = ReefColors.cellIcons
        }
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if !blurView.isDescendant(of: navigationController!.view) {
            navigationController!.view.addSubview(blurView)
        }
    }
    
    private func removeBlur() {
        blurView.removeFromSuperview()
    }
    
    private func set(_ theme: Theme.Type) {
        ReefColors.set(theme: theme)
        
        navigationController?
            .navigationBar
            .largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] = ReefColors.largeTitle
        
        for viewController in navigationController!.viewControllers {
            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()
            if let viewController = viewController as? ThemeCompatible {
                viewController.reloadColors()
            }
        }
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
        set(item.theme)
    }
}

extension ThemeSelectViewController: ThemeSelectionViewModelDelegate {
    func didStartPurchasing(product productID: String) {
        applyBlur()
    }
    
    func didCompletePurchasing(product productID: String) {
        removeBlur()
        select(productID)
    }
    
    func didFailPurchasing(product productID: String) {
        removeBlur()
    }
    
    func didRestorePurchasing(product productID: String) {
        removeBlur()
        select(productID)
    }
    
    func didDeferPurchasing(product productID: String) {
        //code
    }
    
    func didLoadProducts() {
        tableView.reloadData()
        if let row = viewModel.data.firstIndex(where: { $0.theme == ReefColors.theme }) {        
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    func select(_ productID: String) {
        if let row = (viewModel.data.firstIndex{ $0.product?.productIdentifier == productID }) {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            set(viewModel.data[row].theme)
        }
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
