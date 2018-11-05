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
        
        let pullDownViewCollapsedConstraint: CGFloat = 0
        
        let pullDownViewExpandedConstraint: CGFloat =
            taskCreationFrameViewController.taskTitleViewHeight + pullDownViewCollapsedConstraint
        
        let newTaskViewOrigin =
            taskCreationFrameViewController.taskTitleViewHeight + taskCreationFrameViewController.taskTitleAndDetailSeparatorHeight
        let editTaskViewOrigin =
            newTaskViewOrigin + taskCreationFrameViewController.taskDetailViewHeight
        
        containerView.addSubview(toViewController.view)
        toViewController.view.layoutIfNeeded()
        
        toViewController.view.alpha = 1
        taskCreationFrameViewController.taskTitleView.layer.shadowOpacity = 0
        taskCreationFrameViewController.blurView.alpha = 0
        taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
            -taskCreationFrameViewController.taskContainerViewHeight
        
        taskCreationFrameViewController.newTaskViewController.view.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMinYCorner ]
        taskCreationFrameViewController.view.layoutIfNeeded()

        print(taskCreationFrameViewController.taskContainerViewHeight)
        
        let options: UIView.KeyframeAnimationOptions = [ .allowUserInteraction, .calculationModeLinear ]
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: options,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                                        homeScreenViewController.pullDownViewTopConstraint.constant =
                                            pullDownViewExpandedConstraint
                                        homeScreenViewController.view.layoutIfNeeded()
                                        
                                        taskCreationFrameViewController.taskContainerView.frame.origin.y += taskCreationFrameViewController.viewModel.isEditing
                                            ? editTaskViewOrigin
                                            : newTaskViewOrigin
                                    }
        }, completion: { _ in
            let transitionCanceled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionCanceled)
            
            taskCreationFrameViewController.taskContainerViewTopConstraint.constant = taskCreationFrameViewController.viewModel.isEditing
                ? -taskCreationFrameViewController.taskTitleViewHeight - taskCreationFrameViewController.taskTitleAndDetailSeparatorHeight - taskCreationFrameViewController.taskDetailViewHeight
                : -taskCreationFrameViewController.taskDetailViewHeight
            
            if transitionCanceled {
                homeScreenViewController.pullDownViewTopConstraint.constant =
                    pullDownViewCollapsedConstraint
                taskCreationFrameViewController.taskContainerViewTopConstraint.constant =
                    -taskCreationFrameViewController.taskContainerViewHeight
            } else {
                UIView.animateKeyframes(withDuration: 0.25,
                                        delay: 0,
                                        options: .calculationModePaced,
                                        animations: {
                                            
                                            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.0) {
                                                homeScreenViewController.pullDownStackView.alpha = 0
                                                
                                                homeScreenViewController.view.layoutIfNeeded()
                                                
                                                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                                                
                                                animation.fromValue = 0.0
                                                animation.toValue = 1.0
                                                animation.duration = 0.2
                                                
                                                taskCreationFrameViewController
                                                    .taskTitleView
                                                    .layer.add(animation, forKey: animation.keyPath)
                                                taskCreationFrameViewController.taskTitleView.layer.shadowOpacity = 1
                                            }
                                            
                                            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                                                taskCreationFrameViewController.newTaskViewController.view.layer
                                                    .maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner,
                                                                       .layerMaxXMaxYCorner, .layerMinXMinYCorner ]
                                                homeScreenViewController.pullDownViewTopConstraint.constant = 0
                                                taskCreationFrameViewController.blurView.alpha = 1
                                                homeScreenViewController.view.layoutIfNeeded()
                                            }
                                            
                }, completion: { completed in
                    homeScreenViewController.view.layoutIfNeeded()
                    homeScreenViewController.pullDownStackView.alpha = 1
                    taskCreationFrameViewController.newTaskViewController.start()
                })
            }
        })
    }
    
}
