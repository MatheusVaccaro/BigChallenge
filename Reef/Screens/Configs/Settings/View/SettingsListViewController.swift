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
    
    private var closeButton: UIImageView?
    
    var viewModel: SettingsListViewModel!
    
    weak var delegate: SettingsListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
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
        
        reloadColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.hidesBackButton = true
        configureCloseButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeCloseButton()
    }
    
    fileprivate func configureCloseButton() {
        guard closeButton == nil else {
            closeButton?.isHidden = false
            return
        }
        
        let navBar = navigationController!.navigationBar
        
        closeButton = UIImageView(image: UIImage(named: "closeButton")?.withRenderingMode(.alwaysTemplate))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSettings))
        
        closeButton!.tintColor = ReefColors.largeTitle
        closeButton!.translatesAutoresizingMaskIntoConstraints = false
        closeButton!.isUserInteractionEnabled = true
        closeButton!.addGestureRecognizer(tapGesture)
        
        navBar.addSubview(closeButton!)
        
        NSLayoutConstraint.activate([ //TODO: Check constraints
            closeButton!.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -25),
//            closeButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -16),
            closeButton!.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            closeButton!.heightAnchor.constraint(equalTo: navBar.heightAnchor, multiplier: 0.3),
            closeButton!.widthAnchor.constraint(equalTo: closeButton!.heightAnchor)
            ])
    }
    
    private func removeCloseButton() {
        closeButton?.isHidden = true
    }
    
    @objc func closeSettings() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        _ = navigationController?.popViewController(animated: false)
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
        if indexPath.section == 0, indexPath.row == 0 {
            delegate?.didPressThemeCell()
        }
        if indexPath.section == 0, indexPath.row == 1 {
            ReefStore.restorePurchases()
            //do something else
        }
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

extension SettingsListViewController: ThemeCompatible {
    func reloadColors() {
        tableView.reloadData()
        view.backgroundColor = ReefColors.background
        closeButton?.tintColor = ReefColors.largeTitle
        navigationItem.backBarButtonItem?.tintColor = ReefColors.largeTitle
    }
}
