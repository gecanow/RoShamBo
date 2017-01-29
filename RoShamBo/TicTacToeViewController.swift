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
    
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var smallText: UILabel!
    
    var mySign : String!
    var notMySign : String!
    var doIStart : Bool!
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
        
        cellArray = [cell0, cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8]
        for num in 0...8 {
            cellArray[num].number = num
        }
        
        if doIStart! {
            mySign = "X"
            notMySign = "O"
            smallText.text = "it is your turn to place an \(mySign!):"
        } else {
            mySign = "O"
            notMySign = "X"
            smallText.text = "they start"
        }
    }
    
    func restartGame() {
        mainText.text = "play TicTacToe by tapping on one of the cells below!"
        for cell in cellArray {
            if doIStart! {
                smallText.text = "it is your turn to place an \(mySign!):"
                cell.isEnabled = true
            } else {
                smallText.text = "their turn"
                cell.isEnabled = false
            }
            cell.open = true
            cell.text = ""
            cell.setTitle("", for: .normal)
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
    // Handles when any cell is tapped
    //===========================================
    @IBAction func onTappedCell(_ sender: Cell) {
        smallText.text = "their turn"
        sender.setTitle(mySign, for: .normal)
        sender.open = false
        sender.text = mySign
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
        cellArray[number].setTitle(notMySign, for: .normal)
        cellArray[number].open = false
        cellArray[number].text = notMySign
        
        if !determineWinner() {
            // it's my turn
            smallText.text = "it is your turn to place an \(mySign!):"
            for cell in cellArray {
                if cell.open { cell.isEnabled = true }
                else { cell.isEnabled = false }
            }
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
            rematchAlert()
        } else if data.isEqual(to: "ACCEPTED_REMATCH") {
            DispatchQueue.main.async(execute: {
                self.doIStart = true
                self.restartGame()
            })
        } else if data.isEqual(to: "DECLINED_REMATCH") {
            sendAlertWithExitOption(info: "\(peerName) declined your rematch.")
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
        if checkCells(cellArray[0], gl2: cellArray[1], gl3: cellArray[2]) {
            endGame(winningSign: cellArray[0].text)
            return true
        } else if checkCells(cellArray[3], gl2: cellArray[4], gl3: cellArray[5]) {
            endGame(winningSign: cellArray[3].text)
            return true
        } else if checkCells(cellArray[6], gl2: cellArray[7], gl3: cellArray[8]) {
            endGame(winningSign: cellArray[6].text)
            return true
        } else if checkCells(cellArray[0], gl2: cellArray[3], gl3: cellArray[6]) {
            endGame(winningSign: cellArray[0].text)
            return true
        } else if checkCells(cellArray[1], gl2: cellArray[4], gl3: cellArray[7]) {
            endGame(winningSign: cellArray[1].text)
            return true
        } else if checkCells(cellArray[2], gl2: cellArray[5], gl3: cellArray[8]) {
            endGame(winningSign: cellArray[2].text)
            return true
        } else if checkCells(cellArray[0], gl2: cellArray[4], gl3: cellArray[8]) {
            endGame(winningSign: cellArray[0].text)
            return true
        } else if checkCells(cellArray[2], gl2: cellArray[4], gl3: cellArray[6]) {
            endGame(winningSign: cellArray[2].text)
            return true
        } else if gameIsOver() {
            endGame(winningSign: "Cat's Game")
            return true
        } else {
            return false
        }
    }
    
    //=============================================
    // Checks three cells and returns true
    // if they are all the same
    //=============================================
    func checkCells(_ gl1: Cell, gl2: Cell, gl3: Cell) -> Bool {
        if gl1.text != "" && gl1.text == gl2.text && gl1.text == gl3.text {
            return true
        }
        return false
    }
    
    //=============================================
    // Returns true is the game is over
    //=============================================
    func gameIsOver() -> Bool {
        for cell in cellArray {
            if cell.open { return false }
        }
        return true
    }
    
    //=============================================
    // Handles when a game is over
    //=============================================
    func endGame(winningSign: String) {
        for cell in cellArray {
            cell.isEnabled = false
        }
        rematchButton.isEnabled = true
        smallText.text = ""
        
        // update the text here
        if winningSign == "Cat's Game" {
            mainText.text = "Cat's Game"
        } else if winningSign == mySign {
            mainText.text = "You Win!"
            let newScore = UserDefaults.standard.integer(forKey: "TTT-score") + 1
            UserDefaults.standard.set(newScore, forKey: "TTT-score")
        } else {
            mainText.text = "You Lose"
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
                self.doIStart = false
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
