//
//  WaitingViewController.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 8/25/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    func callSegue() {
        self.performSegue(withIdentifier: "waitingSegue", sender: self)
    }
}
