//
//  MPCManager.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 8/6/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// protocol for the main view controller
protocol MPCManagerMainDelegate {
    func reload()
    func invitationWasReceived(_ fromPeer: String)
    func connectedWithPeer(_ peerID: MCPeerID)
    func connectingWithPeer(_ peerID: MCPeerID)
    func couldNotConnectToSession()
}

// protocol for the game view controller
protocol MPCManagerGameViewDelegate {
    func received(_ data: NSString)
    func peerExitedGame()
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var peer : MCPeerID!
    var session : MCSession!
    var browser : MCNearbyServiceBrowser!
    var advertiser : MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var inviteHandler : ((Bool, MCSession) -> Void)!
    
    var mainDelegate : MPCManagerMainDelegate?
    var gameViewDelegate : MPCManagerGameViewDelegate?
    
    var occupiedWithGame = false
    
    //=====================================================
    // INIT
    //=====================================================
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcodax-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcodax-mpc")
        advertiser.delegate = self
    }
    
    //=====================================================
    // Handles browsing for other peers
    //=====================================================
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        mainDelegate?.reload()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.index(of: peerID) {
            foundPeers.remove(at: index)
        }
        mainDelegate?.reload()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //print(error.localizedDescription)
    }
    
    //=====================================================
    // Handles receiving an invite
    //=====================================================
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.inviteHandler = invitationHandler
        mainDelegate?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //print(error.localizedDescription)
    }
    
    //=====================================================
    // Handles a connected session
    //=====================================================
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            //print("connected to session \(session)")
            mainDelegate?.connectedWithPeer(peerID)
        } else if state == .connecting {
            //print("connecting to session \(session)")
            DispatchQueue.main.async(execute: { 
                self.mainDelegate?.connectingWithPeer(peerID)
            })
        } else {
            //print("could not connect to session \(session)")
            DispatchQueue.main.async(execute: {
                
                if self.occupiedWithGame {
                    self.gameViewDelegate?.peerExitedGame()
                } else {
                    self.mainDelegate?.couldNotConnectToSession()
                }
            })
        }
    }
    
    //=====================================================
    // Received data from remote peer
    //=====================================================
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        gameViewDelegate?.received(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
    }
    
    //=====================================================
    // Handles sending data to a peer
    //=====================================================
    func sendData(_ string: String, toPeer targetPeer: MCPeerID) {
        let dataToSend = string.data(using: String.Encoding.utf8)
        let peersArray = NSArray(object: targetPeer)
        
        try! session.send(dataToSend!, toPeers: peersArray as! [MCPeerID], with: .unreliable)
    }
    
    //=====================================================
    // Received a byte stream from remote peer
    //=====================================================
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
    }
    
    //=====================================================
    // Start receiving a resource from remote peer
    //=====================================================
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
    }
    
    //=====================================================
    // Finished receiving a resource from remote peer and 
    // saved the content in a temporary location - the app 
    // is responsible for moving the file to a permanent 
    // location within its sandbox
    //=====================================================
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?){
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func resetPeerID(toName: String) {
        // first tell the advertiser to stop and the browser to stop
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        
        // then set the found peers array to an empty array
        foundPeers = [MCPeerID]()
        mainDelegate?.reload()
        
        // then reset everything else (all from viewDidLoad function)
        peer = MCPeerID(displayName: toName)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcodax-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcodax-mpc")
        advertiser.delegate = self
        
        // then re-advertise and re-browse
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
}
