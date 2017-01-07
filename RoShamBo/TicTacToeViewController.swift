//
//  TicTacToeViewController.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 1/6/17.
//  Copyright © 2017 Gaby Ecanow. All rights reserved.
//

import UIKit

class TicTacToeViewController: UIViewController, MPCManagerGameViewDelegate {
    
    @IBOutlet weak var rematchButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mpc : MPCManager!
    var peerName = ""
    var alert = UIAlertController()
    
    var mySign : String!
    var notMySign : String!
    @IBOutlet weak var cell0: Cell!
    @IBOutlet weak var cell1: Cell!
    @IBOutlet weak var cell2: Cell!
    @IBOutlet weak var cell3: Cell!
    @IBOutlet weak var cell4: Cell!
    @IBOutlet weak var cell5: Cell!
    @IBOutlet weak var cell6: Cell!
    @IBOutlet weak var cell7: Cell!
    @IBOutlet weak var cell8: Cell!
    var cellArray : [Cell]!
    
    //===========================================
    // VIEW DID LOAD
    //===========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        mpc = appDelegate.mpcManager
        
        mpc.gameViewDelegate = self
        mpc.advertiser.stopAdvertisingPeer()
        mpc.occupiedWithGame = true
        
        peerName = mpc.session.connectedPeers[0].displayName
        
        
        if mpc.peer.displayName < peerName {
            mySign = "X"
            notMySign = "O"
        } else {
            mySign = "O"
            notMySign = "X"
        }
        cellArray = [cell0, cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8]
    }
    
    func restartGame() {
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
    // Enables all the buttons to
    // allow you to go
    //===========================================
    func itsMyTurn() {
        for cell in cellArray {
            if cell.open { cell.isEnabled = true }
        }
        
        // then make the label say it's your turn
        
    }
    
    //===========================================
    // Handles when any cell is tapped
    //===========================================
    @IBAction func onTappedCell(_ sender: Cell) {
        sender.setTitle(mySign, for: .normal)
        sender.open = false
        safetyCheck(dataToSend: String(sender.number))
        
        for cell in cellArray {
            cell.isEnabled = false
        }
        
        let _ = determineWinner()
    }
    
    //===========================================
    // Handles when they tapped a cell
    //===========================================
    func theyTappedCell(number: Int) {
        cellArray[number].open = false
        cellArray[number].setTitle(notMySign, for: .normal)
        
        if !determineWinner() {
            itsMyTurn()
        }
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
            // they want a rematch
        } else if data.isEqual(to: "ACCEPTED_REMATCH") {
            // they accepted your rematch
        } else if data.isEqual(to: "DECLINED_REMATCH") {
            // they declined your rematch
        } else {
            DispatchQueue.main.async(execute: { 
                self.theyTappedCell(number: data.integerValue)
            })
        }
    }
    
    //===========================================
    // Determines the winner
    //===========================================
    func determineWinner() -> Bool {
        
        // *** DETERMINE THE WINNER HERE *** //
        
        return false
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
