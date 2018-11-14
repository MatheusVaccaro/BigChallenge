//
//  SettingsListViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class SettingsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SettingsListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsCell", bundle: nil),
                           forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        
        tableView.estimatedRowHeight = 34
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        // Do any additional setup after loading the view.
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
        headerLabel.font = UIFont.font(sized: 14, weight: .light, with: .headline)
        headerLabel.textAlignment = .right
        
        var imageView: UIImageView?
        
        if let image = UIImage(named: "dateIcon") {
            imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            imageView?.tintColor = ReefColors.theme.sectionHeaderIcon
        }
        
        headerLabel.text = "Section \(section)"
        headerLabel.textColor = ReefColors.theme.sectionHeaderLabel
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.sizeToFit()
        headerLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16),
            headerLabel.topAnchor.constraint(greaterThanOrEqualTo: headerView.topAnchor),
            headerLabel.leftAnchor.constraint(greaterThanOrEqualTo: headerView.leftAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: headerLabel.frame.height)
            ])
        
        if let imageView = imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
                imageView.rightAnchor.constraint(equalTo: headerLabel.leftAnchor, constant: -3),
                imageView.leftAnchor.constraint(greaterThanOrEqualTo: headerView.leftAnchor, constant: 16),
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
