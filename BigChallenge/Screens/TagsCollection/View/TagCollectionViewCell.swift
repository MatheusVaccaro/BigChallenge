//
//  TagCollectionViewCell.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    static let identifier = "tagCollectionCell"
    
    var size: CGSize!
    @IBOutlet weak var tagUILabel: UILabel!
    
    private var viewModel: TagCollectionViewCellViewModel!
    
    func configure(with viewModel: TagCollectionViewCellViewModel) {
        self.viewModel = viewModel
        
        tagUILabel.text = viewModel.tagTitle
        tagUILabel.sizeToFit()
        size = tagUILabel.bounds.size
    }
}
