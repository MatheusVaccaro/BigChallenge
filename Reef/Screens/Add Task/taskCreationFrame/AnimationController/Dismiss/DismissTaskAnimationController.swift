//
//  DismissTaskAnimationController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class DismissTaskAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let taskCreationFrameViewController = fromViewController.children.first as? TaskCreationFrameViewController
            else { return }
        
        let duration = transitionDuration(using: transitionContext)
        
        taskCreationFrameViewController.taskContainerViewTopConstraint.constant = 30
        
        UIView.animate(withDuration: duration, animations: {
            taskCreationFrameViewController.view.layoutIfNeeded()
        }) { _ in
            let transitionCanceled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionCanceled)
            if transitionCanceled {
                taskCreationFrameViewController.taskContainerViewTopConstraint.constant = 73
            }
        }
    }
    
}
