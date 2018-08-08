//
//  TagCollectionViewCellViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class TagCollectionViewCellViewModel {
    
    private(set) var tag: Tag
    
    private let disposeBag = DisposeBag()
    
    init(with tag: Tag) {
        self.tag = tag
    }
    
    lazy var tagTitle: String = {
       return tag.title!
    }()
    
    lazy var color: [CGColor] = {
        return TagModel.tagColors[ Int(tag.color) ]
    }()
}
