//
//  TagsCollectionView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 19/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TagCollectionView: UICollectionView {
    var touchedEvent: PublishSubject<UITouch> = PublishSubject()
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchedEvent.onNext(touch)
    }
}
