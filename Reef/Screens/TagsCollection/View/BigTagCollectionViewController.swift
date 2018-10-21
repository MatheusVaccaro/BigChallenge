//
//  bigTagCollectionView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class BigTagCollectionViewController: TagCollectionViewController {
    
    override class var tagViewControllerID: String {
        return "BigTagCollectionViewController"
    }
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsLabel.text = ""
        self.collectionViewHeightConstraint.constant =
            self.tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.filtering = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        viewModel.filtering = true
        viewModel.presentingActionSheet = false
        dismiss(animated: true)
    }
}
