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
import ReefKit

class TagCollectionViewCellViewModel {
    
    private(set) var tag: Tag
    private(set) var longPressedTag: PublishSubject<Tag> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init(with tag: Tag) {
        self.tag = tag
    }
    
    lazy var tagTitle: String = {
       return tag.title!
    }()
    
    lazy var colors: [CGColor] = {
        return tag.colors
    }()
}
