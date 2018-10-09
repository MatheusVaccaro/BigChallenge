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
    
    private weak var taskCoordinator: NewTaskCoordinator?
    private weak var view: UIView?
    
    private(set) var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private var presenter: UIViewController!
    private var presented: UIViewController!
    private var completionHandler: CompletionHandler?
    private var gestureRecognizer: UIPanGestureRecognizer!
    private var attached: Bool = false
    
    init(view: UIView, taskCoordinator: NewTaskCoordinator) {
        self.view = view
        self.taskCoordinator = taskCoordinator
        super.init()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.gestureRecognizer = gestureRecognizer
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let taskCoordinator = taskCoordinator else { return }
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.y / view!.bounds.height)
        progress = min(max(progress, 0.0), 1.0)
        let state = gestureRecognizer.state
        switch state {
        case .began:
            interactionInProgress = true
            taskCoordinator.start()
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
            } else {
                cancel()
                taskCoordinator.delegate?.shouldDeinitCoordinator(taskCoordinator)
            }
        default:
            break
        }
    }
}
