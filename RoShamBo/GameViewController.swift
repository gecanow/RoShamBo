//
//  GameViewController.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 8/6/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, MPCManagerGameViewDelegate {
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var myChoice = ""
    var theirChoice = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //===========================================
    // VIEW DID LOAD
    //===========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mpcManager.gameViewDelegate = self
        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        activityIndicator.isHidden = true
    }
    
    //===========================================
    // Handles when the user taps rock, paper, 
    // or scissors
    //===========================================
    @IBAction func onTappedOption(_ sender: UIButton) {
        myChoice = (sender.currentTitle?.uppercased())!
        
        rockButton.isEnabled = false
        paperButton.isEnabled = false
        scissorsButton.isEnabled = false
        
        winnerLabel.text = "Determining Winner"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        appDelegate.mpcManager.sendData(myChoice, toPeer: appDelegate.mpcManager.session.connectedPeers[0])
        determineWinner()
    }
    
    //===========================================
    // Delegate function: is called when the
    // connected peer chose rock, paper, or
    // scissors
    //===========================================
    func received(_ data: NSString) {
        if data.isEqual(to: "ROCK") {
            theirChoice = "ROCK"
        } else if data.isEqual(to: "PAPER") {
            theirChoice = "PAPER"
        } else {
            theirChoice = "SCISSORS"
        }
        determineWinner()
    }
    
    //===========================================
    // Determines the winner
    //===========================================
    func determineWinner() {
        if myChoice != "" && theirChoice != "" {
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
            if myChoice == theirChoice {
                winnerLabel.text = "Tie Game!"
            } else if (myChoice == "ROCK" && theirChoice == "SCISSORS") ||
                      (myChoice == "SCISSORS" && theirChoice == "PAPER") ||
                      (myChoice == "PAPER" && theirChoice == "ROCK") {
                winnerLabel.text = "You Win!"
            } else {
                winnerLabel.text = "You Lose..."
            }
            
        }
    }
}
