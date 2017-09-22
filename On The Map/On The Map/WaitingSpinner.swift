//
//  WaitingSpinner.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import UIKit

class WaitingSpinner {
	//MARK: Properties
	
	var blurView: UIVisualEffectView? = nil
	var spinnerView: UIActivityIndicatorView? = nil
	
	//MARK: Functions
	
	func show(_ viewController: UIViewController) {
		//first add blur view to blur screen contents
		blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		blurView!.frame = viewController.view.bounds
		viewController.view.addSubview(blurView!)
		
		//then add a spinner in the center
		spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinnerView?.center = viewController.view.center
		spinnerView?.startAnimating()
		viewController.view.addSubview(spinnerView!)
	}
	
	func hide() {
		if (blurView != nil) {
			blurView!.removeFromSuperview()
			blurView = nil
		}
		
		if (spinnerView != nil) {
			spinnerView!.removeFromSuperview()
			spinnerView = nil
		}
	}
}
