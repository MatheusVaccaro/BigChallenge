//
//  PresentTaskInteractiveAnimationController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 03/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class PresentTaskInteractiveAnimationController: UIPercentDrivenInteractiveTransition {
    
    typealias CompletionHandler = () -> Void
    
    private(set) var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private var presenter: UIViewController
    private var completionHandler: CompletionHandler?
    private var gestureRecognizer: UIPanGestureRecognizer!
    private var view: UIView
    
    init(presenter: UIViewController, view: UIView, completionHandler: CompletionHandler? = nil) {
        self.view = view
        self.presenter = presenter
        super.init()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.gestureRecognizer = gestureRecognizer
        self.completionHandler = completionHandler
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.y / 38)
        progress = min(max(progress, 0.0), 1.0)
        let state = gestureRecognizer.state
        switch state {
        case .began:
            interactionInProgress = true
            presenter.dismiss(animated: true)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
                completionHandler?()
                view.removeGestureRecognizer(gestureRecognizer)
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
