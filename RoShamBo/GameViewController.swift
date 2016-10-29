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
    @IBOutlet weak var rematchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var myChoice = ""
    var theirChoice = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mpc : MPCManager!
    var peerName = ""
    
    //===========================================
    // VIEW DID LOAD
    //===========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        mpc = appDelegate.mpcManager
        
        mpc.gameViewDelegate = self
        mpc.advertiser.stopAdvertisingPeer()
        mpc.occupiedWithGame = true
        
        activityIndicator.isHidden = true
        peerName = mpc.peer.displayName
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
        
        mpc.sendData(myChoice, toPeer: mpc.session.connectedPeers[0])
        determineWinner()
    }
    
    //===========================================
    // Handles when the user taps exit
    //===========================================
    @IBAction func onTappedExit(_ sender: UIButton) {
        if mpc.session.connectedPeers.count > 0 {
            mpc.sendData("EXIT", toPeer: mpc.session.connectedPeers[0])
        }
        dismissSelf()
    }
    
    @IBAction func onTappedRematch(_ sender: UIButton) {
        mpc.sendData("REMATCH", toPeer: mpc.session.connectedPeers[0])
    }
    
    //===========================================
    // Delegate function: is called when the
    // connected peer chose rock, paper,
    // scissors, exit, or rematch
    //===========================================
    func received(_ data: NSString) {
        if data.isEqual(to: "EXIT") {
            peerExitedGame()
        } else if data.isEqual(to: "REMATCH") {
            print("recieved a rematch request")
            rematchAlert()
        } else if data.isEqual(to: "ACCEPTED_REMATCH") {
            //print("they accepted my rematch!")
        } else if data.isEqual(to: "DECLINED_REMATCH") {
            //print("they declined my rematch :(")
        } else if data.isEqual(to: "ROCK") {
            theirChoice = "ROCK"
        } else if data.isEqual(to: "PAPER") {
            theirChoice = "PAPER"
        } else {
            theirChoice = "SCISSORS"
        }
        
        determineWinner()
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(determineWinner), userInfo: nil, repeats: false)
    }
    
    func rematchAlert() {
        let alert = UIAlertController(title: "\(peerName) would like a rematch!", message: "Tap 'Accept' to accept their challenge!", preferredStyle: .alert)
        
        let accept = UIAlertAction(title: "Accept", style: .default, handler: { (Void) in
            self.mpc.sendData("ACCEPTED_REMATCH", toPeer: self.mpc.session.connectedPeers[0])
        })
        let decline = UIAlertAction(title: "Decline", style: .cancel) { (Void) in
            self.mpc.sendData("DECLINED_REMATCH", toPeer: self.mpc.session.connectedPeers[0])
        }
        
        alert.addAction(accept)
        alert.addAction(decline)
        
        present(alert, animated: true, completion: nil)
    }
    
    //===========================================
    // Determines the winner
    //===========================================
    func determineWinner() {
        
        print("here, determining the winner!!!!!!! (or at least trying to...)")
        
        if (myChoice != "" && theirChoice != "") {
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
            if myChoice == theirChoice {
                winnerLabel.text = "Tie Game!"
            } else if (myChoice == "ROCK" && theirChoice == "SCISSORS") ||
                      (myChoice == "SCISSORS" && theirChoice == "PAPER") ||
                      (myChoice == "PAPER" && theirChoice == "ROCK") {
                winnerLabel.text = "You Win!"
            } else {
                winnerLabel.text = "You Lose!"
            }
            rematchButton.isEnabled = true
            
        }
    }
    
    //===========================================
    // Delegate function: is called when the
    // peer exited the game
    //===========================================
    func peerExitedGame() {
        rematchButton.isEnabled = false
        
        let alert = UIAlertController(title: "\(peerName) has exited the game.", message: "", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    //===========================================
    // Display an alert with title mainMessage 
    // and message smallMessage
    //===========================================
//    func displayAlert(mainMessage: String, smallMessage: String) {
//        
//        let alert = UIAlertController(title: mainMessage, message: smallMessage, preferredStyle: .alert)
//        
//        let okayAction = UIAlertAction(title: "OK", style: .default, handler: { (Void) in
//            //self.dismissSelf()
//        })
//        
//        alert.addAction(okayAction)
//        present(alert, animated: true, completion: nil)
//    }
    
    //===========================================
    // Handles dismissing the game view
    //===========================================
    func dismissSelf() {
        self.dismiss(animated: true) {
            self.mpc.occupiedWithGame = false
            self.mpc.resetPeerID(toName: self.mpc.peer.displayName)
        }
    }
}
