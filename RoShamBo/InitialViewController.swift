//
//  InitialViewController.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 1/5/17.
//  Copyright © 2017 Gaby Ecanow. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        displayNameTextField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mvc = segue.destination as! ViewController
        mvc.prefferedDisplayName = displayNameTextField.text
    }
}
