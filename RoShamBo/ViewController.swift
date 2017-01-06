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
    
    var prefferedDisplayName : String?
    
    //=====================================================
    // VIEW DID LOAD
    //=====================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mpcManager.mainDelegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        appDelegate.mpcManager.resetPeerID()
        
        displayNameLabel.text = "your display name: \(appDelegate.mpcManager.peer.displayName)"
    }
    
    func enteredDisplayName() -> String? {
        return prefferedDisplayName
    }
    
    @IBAction func onTappedQuestion(_ sender: AnyObject) {
        informationView.isHidden = !informationView.isHidden
    }
    
    @IBAction func onTappedEdit(_ sender: AnyObject) {
        let ti = "Please enter a display name."
        let me = "This will be the name by which your friends can find you."
        let alert = UIAlertController(title: ti, message: me, preferredStyle: .alert)
        
        alert.addTextField { (_ textfield: UITextField) in
            textfield.keyboardType = .alphabet
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (Void) in
            self.prefferedDisplayName = (alert.textFields?.first?.text)!
            self.displayNameLabel.text = "your display name: \(self.prefferedDisplayName)"
            self.appDelegate.mpcManager.resetPeerID()//toName: self.prefferedDisplayName)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //=====================================================
    // The unwind segue function for the exit button on
    // the instructions page
    //=====================================================
    @IBAction func unwindFromInstructions(segue: UIStoryboardSegue) {}
    
    //=====================================================
    // DELEGATE FUNCTIONS
    //=====================================================
    func reload() {
        tablePeers.reloadData()
    }
    
    func invitationWasReceived(_ fromPeer: String) {
        let title = "\(fromPeer) would like to connect with you."
        let message = "Tap 'Accept' to connect or 'Decline' to reject."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (Void) in
            self.appDelegate.mpcManager.inviteHandler(true, self.appDelegate.mpcManager.session)
        }
        let declineAction = UIAlertAction(title: "Decline", style: .cancel) { (Void) in
            self.appDelegate.mpcManager.inviteHandler(false, self.appDelegate.mpcManager.session) //nil
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func connectedWithPeer(_ peerID: MCPeerID) {
        self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "gameSegue", sender: self)
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
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, to: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    //=====================================================
    // Switches between whether the advertising is on
    // or off
    //=====================================================
    @IBAction func onSwitchedAdvertiser(_ sender: UISwitch) {
        if sender.isOn {
            appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        } else {
            appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        }
    }
    
    
    //=====================================================
    // Handles when a session could not be connected to
    //=====================================================
    func couldNotConnectToSession() {
        let title = "We're Sorry"
        let message = "The bluetooth/wifi is not working in your area."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        
        self.dismiss(animated: true) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

