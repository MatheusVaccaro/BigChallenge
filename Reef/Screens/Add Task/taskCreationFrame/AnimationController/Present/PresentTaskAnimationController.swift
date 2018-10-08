//
//  PresentTaskAnimationController.swift
//  Reef
//
//  Created by Matheus Vaccaro on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class PresentTaskAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
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
        
        homeScreenViewController.pullDownViewTopConstraint.constant =
            homeScreenViewController.pullDownViewExpandedConstraint
        taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
            -taskCreationFrameViewController.taskDetailViewHeight
        
        UIView.animate(withDuration: duration,
                       delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            fromViewController.view.layoutIfNeeded()
        }, completion: { _ in
            toViewController.view.isHidden = false
            homeScreenViewController.pullDownViewTopConstraint.constant =
                homeScreenViewController.pullDownViewCollapsedConstraint
            let transitionCanceled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionCanceled)
            if transitionCanceled {
                taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                    -taskCreationFrameViewController.taskContainerViewHeight
            }
            
        })
        
        
//        
//        UIView.animateKeyframes(withDuration: duration,
//                                delay: 0,
//                                options: [],
//                                animations: {
//                                    UIView.addKeyframe(withRelativeStartTime: <#T##Double#>, relativeDuration: <#T##Double#>) {
//
//                                    }
//        }, completion: { _ in
//            
//        })
//        
//        
        
        
        
        
        
        
        
        
        
        
        
    }
    
}
