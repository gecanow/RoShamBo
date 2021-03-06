//
//  ViewController.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 8/6/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerMainDelegate {
    
    @IBOutlet weak var tablePeers: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var scoreInfoView: UIView!
    @IBOutlet weak var gameRequestSentView: UIView!
    @IBOutlet weak var tttScoreView: UILabel!
    @IBOutlet weak var rsbScoreView: UILabel!
    var instigatedGame = true
    
    //=====================================================
    // VIEW DID LOAD
    //=====================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mpcManager.mainDelegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        changeDisplayTo(name: UserDefaults.standard.object(forKey: "displayName") as! String)
    }
    
    //=====================================================
    // VIEW DID APPEAR
    //=====================================================
    override func viewDidAppear(_ animated: Bool) {
        tttScoreView.text = "tictactoe score: \(UserDefaults.standard.integer(forKey: "TTT-score"))"
        rsbScoreView.text = "roshambo score: \(UserDefaults.standard.integer(forKey: "RSB-score"))"
        
        gameRequestSentView.isHidden = true
        informationView.isHidden = true
        scoreInfoView.isHidden = true
    }
    
    //=====================================================
    // Handles when the user taps the question mark
    //=====================================================
    @IBAction func onTappedQuestion(_ sender: AnyObject) {
        informationView.isHidden = !informationView.isHidden
    }
    @IBAction func onTappedScoreQuestion(_ sender: Any) {
        scoreInfoView.isHidden = !scoreInfoView.isHidden
    }
    
    //=====================================================
    // Handles when the user taps "ok" when the game
    // request sent message is shown
    //=====================================================
    @IBAction func onTappedOkRequestSent(_ sender: Any) {
        gameRequestSentView.isHidden = true
    }
    
    
    //=====================================================
    // Handles when the user wants to change their 
    // display name
    //=====================================================
    @IBAction func onTappedEdit(_ sender: AnyObject) {
        let ti = "Please enter a display name."
        let me = "This will be the name by which your friends can find you."
        let alert = UIAlertController(title: ti, message: me, preferredStyle: .alert)
        
        alert.addTextField { (_ textfield: UITextField) in
            textfield.keyboardType = .alphabet
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (Void) in
            self.changeDisplayTo(name: (alert.textFields?.first?.text)!)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //=====================================================
    // A helper function which handles changing both the 
    // internal display name and the display name which 
    // appears on the GUI
    //=====================================================
    func changeDisplayTo(name: String) {
        appDelegate.mpcManager.resetPeerID(toName: name)
        displayNameLabel.text = "your display name: \(name)"
    }
    
    //=====================================================
    // The unwind segue function for the exit button on
    // the instructions page
    //=====================================================
    @IBAction func unwindFromInstructions(segue: UIStoryboardSegue) {}
    
    //=====================================================
    // Handles when the user manually reloads the tableview
    //=====================================================
    @IBAction func onTappedRefresh(_ sender: Any) {
        self.reload()
    }
    
    //=====================================================
    // DELEGATE FUNCTIONS
    //=====================================================
    func reload() {
        DispatchQueue.main.async {
            self.tablePeers.reloadData()
        }
    }
    
    func invitationWasReceived(_ fromPeer: String) {
        var title = "\(fromPeer) would like to connect with you to play "
        if appDelegate.mpcManager.gameChosen == .RSB {
            title += "RoShamBo."
        } else {
            title += "TicTacToe."
        }
        
        let alert = UIAlertController(title: title, message: "Tap 'Accept' to connect or 'Decline' to reject.", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (Void) in
            self.instigatedGame = false
            self.appDelegate.mpcManager.inviteHandler(true, self.appDelegate.mpcManager.session)
        }
        let declineAction = UIAlertAction(title: "Decline", style: .cancel) { (Void) in
            self.appDelegate.mpcManager.inviteHandler(false, nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func connectedWithPeer(_ peerID: MCPeerID) {
        self.dismiss(animated: true) {
            self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
            
            if self.appDelegate.mpcManager.gameChosen == .RSB {
                self.performSegue(withIdentifier: "gameSegue", sender: self)
            } else {
                self.performSegue(withIdentifier: "tictactoeSegue", sender: self)
            }
        }
    }
    
    func connectingWithPeer(_ peerID: MCPeerID) {
        let title = "Connecting you with \(peerID.displayName)."
        let message = ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = alert.view.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        present(alert, animated: true, completion: nil)
    }
    
    //=====================================================
    // Setup and update the tableview of peers
    //=====================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer")! as UITableViewCell
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[(indexPath as NSIndexPath).row].displayName
        return cell
    }
    
    //=====================================================
    // Handles selection of a cell in the tableview
    //=====================================================
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[(indexPath as NSIndexPath).row] as MCPeerID
        
        let actionSheet = UIAlertController(title: "Which game would you like to play with \(selectedPeer.displayName)?", message: "Tap on an option below.", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        let rsb = UIAlertAction(title: "RoShamBo", style: .default) { (Void) in
            self.appDelegate.mpcManager.gameChosen = .RSB
            let myData = "RSB".data(using: .ascii)
            self.appDelegate.mpcManager.browser.invitePeer(selectedPeer, to: self.appDelegate.mpcManager.session, withContext: myData, timeout: 20)
            
            self.gameRequestSentView.isHidden = false
            self.instigatedGame = true
        }
        actionSheet.addAction(rsb)
        
        let ttt = UIAlertAction(title: "TicTacToe", style: .default) { (Void) in
            self.appDelegate.mpcManager.gameChosen = .TTT
            let myData = "TTT".data(using: .ascii)
            self.appDelegate.mpcManager.browser.invitePeer(selectedPeer, to: self.appDelegate.mpcManager.session, withContext: myData, timeout: 20)
            
            self.gameRequestSentView.isHidden = false
            self.instigatedGame = true
        }
        actionSheet.addAction(ttt)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //=====================================================
    // Switches between whether the advertising is on
    // or off
    //=====================================================
    @IBAction func onSwitchedAdvertiser(_ sender: UISwitch) {
        if sender.isOn {
            appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        } else {
            DispatchQueue.main.async {
                self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
            }
        }
    }
    
    
    //=====================================================
    // Handles when a session could not be connected to
    //=====================================================
    func couldNotConnectToSession() {
        var message = "The bluetooth/wifi is not working in your area."
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: nil)
        } else {
            message = "Your game invitation was declined."
        }
        
        let alert = UIAlertController(title: "We're Sorry", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tictactoeSegue" {
            let dvc = segue.destination as! TicTacToeViewController
            dvc.doIStart = instigatedGame
        }
    }
    
}

