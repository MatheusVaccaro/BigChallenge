//
//  TagCollectionViewCellViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class TagCollectionViewCellViewModel {
    
    private var tag: Tag
    
    init(with tag: Tag) {
        self.tag = tag
    }
    
    lazy var tagTitle: String = {
       return tag.title!
    }()
    
    lazy var color: Int16 = {
       return tag.color
    }()
}
