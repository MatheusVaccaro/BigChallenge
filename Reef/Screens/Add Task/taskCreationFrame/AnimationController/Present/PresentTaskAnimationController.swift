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
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let homeScreenViewController = fromViewController.children.first as? HomeScreenViewController,
            let taskCreationFrameViewController = toViewController.children.first as? TaskCreationFrameViewController
            else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        let pullDownViewCollapsedConstraint: CGFloat =
            8
        
        let pullDownViewExpandedConstraint: CGFloat =
            taskCreationFrameViewController.taskTitleViewHeight + pullDownViewCollapsedConstraint
        
        containerView.addSubview(toViewController.view)
        
        toViewController.view.alpha = 0
        
        taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
            -taskCreationFrameViewController.taskContainerViewHeight
        taskCreationFrameViewController.view.layoutIfNeeded()
        
        let options: UIView.KeyframeAnimationOptions = [ .allowUserInteraction,
                                                         .calculationModeCubic ]
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: options,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                                        homeScreenViewController.pullDownViewTopConstraint.constant =
                                            pullDownViewExpandedConstraint
                                        homeScreenViewController.view.layoutIfNeeded()
                                        
                                        taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                                            -taskCreationFrameViewController.taskDetailViewHeight
                                        taskCreationFrameViewController.view.layoutIfNeeded()
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                                        toViewController.view.alpha = 1
                                    }
                                    
        }, completion: { _ in
            let transitionCanceled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionCanceled)
            
            UIView.animateKeyframes(withDuration: 0.2,
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        
                                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                                            homeScreenViewController.pullDownViewHeight.constant = 0
                                            homeScreenViewController.pullDownViewTopConstraint.constant =
                                                -100
                                            
                                            homeScreenViewController.view.layoutIfNeeded()
                                            taskCreationFrameViewController.blurView.alpha = 1
                                        }
            }, completion: { completed in
                if completed {
                    let animation = CABasicAnimation(keyPath: "shadowOpacity")
                    
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    
                    animation.duration = 0.2
                    taskCreationFrameViewController.taskTitleView.layer.add(animation, forKey: animation.keyPath)
                    taskCreationFrameViewController.taskTitleView.layer.shadowOpacity = 1
                    
                    homeScreenViewController.pullDownViewHeight.constant = 100
                }
            })
            
            if transitionCanceled {
                taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                    -taskCreationFrameViewController.taskContainerViewHeight
            }
        })
    }
    
}