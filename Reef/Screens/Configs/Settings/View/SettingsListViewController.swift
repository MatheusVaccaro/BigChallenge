//
//  SettingsListViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol SettingsListViewControllerDelegate: class {
    func didPressThemeCell()
}

class SettingsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SettingsListViewModel!
    
    weak var delegate: SettingsListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ReefColors.background
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.hidesBackButton = true 
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsCell", bundle: nil),
                           forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        
        tableView.estimatedRowHeight = 34
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.estimatedSectionHeaderHeight = 25
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
}

extension SettingsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModel = viewModel.viewModelForCellIn(indexPath) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier,
                                                 for: indexPath) as! SettingsCell
        
        cell.configWith(cellViewModel)
        
        return cell
    }
}

extension SettingsListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row at \(indexPath.row)")
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = view.frame
        
        let headerLabel = UILabel()
        headerLabel.font = UIFont.font(sized: 19, weight: .medium, with: .headline)
        headerLabel.textAlignment = .left
        
        var imageView: UIImageView?
        
        if let image = UIImage(named: viewModel.sectionImageNameFor(section)) {
            imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView?.tintColor = ReefColors.theme.sectionHeaderIcon
        }
        
        headerLabel.text = viewModel.nameFor(section)
        headerLabel.textColor = ReefColors.theme.sectionHeaderLabel
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.sizeToFit()
        headerLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.rightAnchor.constraint(greaterThanOrEqualTo: headerView.rightAnchor, constant: -33),
            headerLabel.topAnchor.constraint(greaterThanOrEqualTo: headerView.topAnchor, constant: 8),
            headerLabel.leftAnchor.constraint(greaterThanOrEqualTo: headerView.leftAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -8),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: headerLabel.frame.height)
            ])
        
        if let imageView = imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
                imageView.rightAnchor.constraint(equalTo: headerLabel.leftAnchor, constant: -4),
                imageView.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 8),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                imageView.heightAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 0.8)
                ])
        }
        return headerView
    }
}

// MARK: - StoryboardInstantiable
extension SettingsListViewController: StoryboardInstantiable {
    
    static var viewControllerID: String {
        return "SettingsListViewController"
    }
    
    static var storyboardIdentifier: String {
        return "SettingsList"
    }
}
