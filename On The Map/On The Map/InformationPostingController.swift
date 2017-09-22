//
//  InformationPostingController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import UIKit

class InformationPostingController: UIViewController {

	//MARK: Outlets
	
	@IBOutlet var mapStringPrompt: UILabel!
	@IBOutlet var mapStringInput: UITextField!
	@IBOutlet var inputContainer: UIStackView!
	@IBOutlet var mediaURLInput: UITextField!
	
	@IBOutlet var buttonContainer: UIStackView!
	@IBOutlet var findOnTheMapButton: UIButton!
	@IBOutlet var submitButton: UIButton!
	
	//MARK: Actions
	
	@IBAction func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: UIViewController overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
		mediaURLInput.isHidden = true
		submitButton.isHidden = true
    }
}
