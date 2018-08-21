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
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(update),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(update),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    var forceTouched: PublishSubject<UITouch> = PublishSubject()
    var impactGenerator: UIImpactFeedbackGenerator?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator?.prepare()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if shouldTriggerForceTouch(on: touch) {
            forceTouched.onNext(touch)
            resetImpactFeedback()
        }
    }
    
    fileprivate func shouldTriggerForceTouch(on touch: UITouch) -> Bool {
        if self.traitCollection.forceTouchCapability == .available {
            let force = touch.force/touch.maximumPossibleForce
            if !mediumImpactOcurred, force >= 0.5 {
                impactGenerator?.impactOccurred()
                mediumImpactOcurred = true
                return true
            } else if !heavyImpactOcurred, force >= 0.6 {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                heavyImpactOcurred = true
                return true
            }
        }
        return false
    }
    
    fileprivate var mediumImpactOcurred: Bool = false
    fileprivate var heavyImpactOcurred: Bool = false
    
    fileprivate func resetImpactFeedback() {
        mediumImpactOcurred = false
        heavyImpactOcurred = false
    }
    
    @objc private func update() {
        reloadData()
    }
}
