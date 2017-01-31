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
        
        if (UserDefaults.standard.object(forKey: "displayName") as? String) != "" {
            displayNameTextField.text = UserDefaults.standard.object(forKey: "displayName") as? String
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "mainScreenSegue", sender: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        displayNameTextField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserDefaults.standard.set(displayNameTextField.text, forKey: "displayName")
    }
}
