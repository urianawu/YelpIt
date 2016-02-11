//
//  SearchNavigationControllerDelegate.swift
//  Yelp
//
//  Created by you wu on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class SearchNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(
        navigationController: UINavigationController,
        animationControllerForOperation operation:
        UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            
            return TransitionManager()
    }
}
