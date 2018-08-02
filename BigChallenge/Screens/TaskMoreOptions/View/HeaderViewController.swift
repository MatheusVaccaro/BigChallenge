//
//  HeaderViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class HeaderViewController: UIViewController {
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with viewModel: MoreOptionsTableViewCellViewModelProtocol) {
        taskTitle.text = viewModel.title()
        subtitle.text = viewModel.subtitle()
        let image = UIImage(named: viewModel.imageName())
        button.setImage(image, for: .normal)
    }
    
}

// MARK: - StoryboardInstantiable

extension HeaderViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return "MoreOptions"
    }
    
    static var viewControllerID: String {
        return "HeaderViewController"
    }
}
