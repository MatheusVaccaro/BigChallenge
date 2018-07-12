//
//  TagsCollectionViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol TagCollectionDelegate: class {
    
}

class TagCollectionViewController: UIViewController {

    var viewModel: TagCollectionViewModel?
    weak var delegate: TagCollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TagCollectionViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "TagCollectionViewController"
    }
    
    static var storyboardIdentifier: String {
        return "TagCollection"
    }
}
