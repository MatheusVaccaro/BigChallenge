//
//  TaskCreationFrameDismissAnimationController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFrameDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let interactionController: SwipeInteractionController?
    
    init(interactionController: SwipeInteractionController? = nil) {
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let homeScreenViewController = toViewController.children.first as? HomeScreenViewController,
            let taskCreationFrameViewController = fromViewController.children.first as? TaskCreationFrameViewController
            else { return }
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
        animator.addAnimations {
            homeScreenViewController.pullDownViewTopConstraint.constant = -22
            homeScreenViewController.view.layoutIfNeeded()
            
            taskCreationFrameViewController.taskContainerViewTopConstraint.constant = -242
            taskCreationFrameViewController.view.layoutIfNeeded()
        }
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
    
}
