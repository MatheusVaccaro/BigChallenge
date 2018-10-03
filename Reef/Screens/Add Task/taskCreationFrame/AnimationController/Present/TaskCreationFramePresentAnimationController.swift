//
//  TaskCreationFramePresentAnimationController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFramePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let homeScreenViewController = fromViewController.children.first as? HomeScreenViewController,
            let taskCreationFrameViewController = toViewController.children.first as? TaskCreationFrameViewController
            else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
    
        containerView.addSubview(toViewController.view)
        toViewController.view.isHidden = true
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
        animator.addAnimations {
            homeScreenViewController.pullDownViewTopConstraint.constant = 30
            homeScreenViewController.view.layoutIfNeeded()
            
            taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                taskCreationFrameViewController.titleInputHeight
            
//            taskCreationFrameViewController.view.layoutIfNeeded()
        }
        
        animator.addCompletion { _ in
            toViewController.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
    
}
