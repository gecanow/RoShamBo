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
    @IBOutlet weak var choiceLabel: UILabel!
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
    var alert = UIAlertController()
    
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
        peerName = mpc.session.connectedPeers[0].displayName
    }
    
    func restartGame() {
        myChoice = ""
        theirChoice = ""
        
        activityIndicator.isHidden = true
        
        winnerLabel.text = "rematch has begun!"
        choiceLabel.text = "you chose: ? | they chose: ?"
        
        rockButton.isEnabled = true
        paperButton.isEnabled = true
        scissorsButton.isEnabled = true
        
        rematchButton.isEnabled = false
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
        
        safetyCheck(dataToSend: myChoice)
        
        DispatchQueue.main.async { 
            self.determineWinner()
        }
    }
    
    //===========================================
    // Handles when the user taps exit
    //===========================================
    @IBAction func onTappedExit(_ sender: UIButton) {
        safetyCheck(dataToSend: "EXIT")
        dismissSelf()
    }
    
    //===========================================
    // Handles when the user taps rematch
    //===========================================
    @IBAction func onTappedRematch(_ sender: UIButton) {
        safetyCheck(dataToSend: "REMATCH")
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
            rematchAlert()
        } else if data.isEqual(to: "ACCEPTED_REMATCH") {
            DispatchQueue.main.async(execute: { 
                self.restartGame()
            })
        } else if data.isEqual(to: "DECLINED_REMATCH") {
            sendAlertWithExitOption(info: "\(peerName) declined your rematch.")
        } else if data.isEqual(to: "ROCK") {
            theirChoice = "ROCK"
        } else if data.isEqual(to: "PAPER") {
            theirChoice = "PAPER"
        } else {
            theirChoice = "SCISSORS"
        }
        
        DispatchQueue.main.async(execute: {
            self.determineWinner()
        })
    }
    
    //===========================================
    // Determines the winner
    //===========================================
    func determineWinner() {
        
        if (myChoice != "" && theirChoice != "") {
            
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
            if myChoice == theirChoice {
                winnerLabel.text = "Tie Game!"
            } else if (myChoice == "ROCK" && theirChoice == "SCISSORS") ||
                      (myChoice == "SCISSORS" && theirChoice == "PAPER") ||
                      (myChoice == "PAPER" && theirChoice == "ROCK") {
                winnerLabel.text = "You Win!"
                let newScore = UserDefaults.standard.integer(forKey: "RSB-score") + 1
                UserDefaults.standard.set(newScore, forKey: "RSB-score")
            } else {
                winnerLabel.text = "You Lose!"
            }
            
            choiceLabel.text = "you chose: \(myChoice.lowercased()) | they chose: \(theirChoice.lowercased())"
            
            rematchButton.isEnabled = true
            
        }
    }
    
    //===========================================
    // Delegate function: is called when the
    // peer exited the game
    //===========================================
    func peerExitedGame() {
        rematchButton.isEnabled = false
        sendAlertWithExitOption(info: "\(peerName) has exited the game.")
    }
    
    //===========================================
    // Handles sending an alert with title 
    // "info" and an OKAY option and as EXIT 
    // option
    //===========================================
    func sendAlertWithExitOption(info: String) {
        if !alert.isBeingPresented {
            alert = UIAlertController(title: info, message: "Press 'Exit' to exit this game.", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            let exitAction = UIAlertAction(title: "Exit", style: .default, handler: { (Void) in
                let fakeButton = UIButton()
                self.onTappedExit(fakeButton)
            })
            
            alert.addAction(okayAction)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //===========================================
    // Handles presenting an alert when the
    // peer has requested a rematch
    //===========================================
    func rematchAlert() {
        if !alert.isBeingPresented {
            alert = UIAlertController(title: "\(peerName) would like a rematch!", message: "Tap 'Accept' to accept their challenge!", preferredStyle: .alert)
            
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (Void) in
                self.safetyCheck(dataToSend: "ACCEPTED_REMATCH")
                self.restartGame()
            })
            let decline = UIAlertAction(title: "Decline", style: .cancel) { (Void) in
                self.safetyCheck(dataToSend: "DECLINED_REMATCH")
            }
            
            alert.addAction(accept)
            alert.addAction(decline)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //===========================================
    // Handles sending data to the peer in a 
    // safe manner by checking first if the peer 
    // is still connected
    //===========================================
    func safetyCheck(dataToSend: String) {
        if mpc.session.connectedPeers.count > 0 {
            mpc.sendData(dataToSend, toPeer: mpc.session.connectedPeers[0])
        }
    }
    
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
