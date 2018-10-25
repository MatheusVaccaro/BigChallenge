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
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let taskCreationFrameViewController = fromViewController.children.first as? TaskCreationFrameViewController,
            let homeScreenViewController = toViewController.children.first as? HomeScreenViewController
            else { return }
        
        let duration = transitionDuration(using: transitionContext)
        
        let pullDownViewCollapsedConstraint: CGFloat =
            0
        
        taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
            -taskCreationFrameViewController.taskContainerViewHeight
        
        UIView.animate(withDuration: duration, animations: {
            taskCreationFrameViewController.view.layoutIfNeeded()
        }, completion: { _ in
            let transitionCanceled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionCanceled)
            
            UIView.animate(withDuration: duration) {
                homeScreenViewController.pullDownViewTopConstraint.constant =
                pullDownViewCollapsedConstraint
                homeScreenViewController.view.layoutIfNeeded()
            }
            
            if transitionCanceled {
                taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                    -taskCreationFrameViewController.taskDetailViewHeight
            }
        })
    }
    
}
