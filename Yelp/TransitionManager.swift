//
//  TransitionManager.swift
//  Yelp
//
//  Created by you wu on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView()
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            
            containerView!.addSubview(toVC!.view)
            toVC!.view.alpha = 0.0
            
            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                toVC!.view.alpha = 1.0
                }, completion: { finished in
                    let cancelled = transitionContext.transitionWasCancelled()
                    transitionContext.completeTransition(!cancelled)
            })
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
