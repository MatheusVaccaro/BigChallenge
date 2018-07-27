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
    
    var isSelected: BehaviorSubject<Bool>
    
    private var tag: Tag
    
    private let disposeBag = DisposeBag()
    
    init(with tag: Tag) {
        self.tag = tag
        isSelected = BehaviorSubject<Bool>(value: false)
    }
    
    lazy var tagTitle: String = {
       return tag.title!
    }()
    
    lazy var color: [CGColor] = {
        return TagModel.tagColors[ Int(tag.color) ]
    }()
    
    func observe(_ subject: BehaviorSubject<[Tag]>) {
        subject.subscribe { event in
            if let selectedTags = event.element {
                if selectedTags.contains(self.tag) {
                    self.isSelected.onNext(true)
                } else {
                    self.isSelected.onNext(false)
                }
            }
        }.disposed(by: disposeBag)
    }
}
