//
//  TagCollectionViewCellViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift
import ReefKit

protocol TagCollectionViewCellDelegate: class {
    func didLongPress(_ tagCollectionViewCellViewModel: TagCollectionViewCellViewModel)
}

class TagCollectionViewCellViewModel {
    
    private(set) var tag: Tag
    
    weak var delegate: TagCollectionViewCellDelegate?
    
    private let disposeBag = DisposeBag()
    
    init(with tag: Tag) {
        self.tag = tag
    }
    
    func performLongPress() {
        delegate?.didLongPress(self)
    }
    
    lazy var tagTitle: String = {
       return tag.title!
    }()
    
    lazy var colors: [CGColor] = {
        return tag.colors
    }()
}
