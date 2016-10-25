//
//  MPCManager.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 8/6/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerMainDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(_ fromPeer: String)
    func connectedWithPeer(_ peerID: MCPeerID)
    func connectingWithPeer(_ peerID: MCPeerID)
    func couldNotConnectToSession()
}

protocol MPCManagerGameViewDelegate {
    func received(_ data: NSString)
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
    
    var recievedData : NSString!
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
    }
    
    //=====================================================
    // Handles browsing for other peers
    //=====================================================
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        mainDelegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.index(of: peerID) {
            foundPeers.remove(at: index)
        }
        mainDelegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    //=====================================================
    // Handles receiving an invite
    //=====================================================
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.inviteHandler = invitationHandler
        mainDelegate?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    //=====================================================
    // Handles a connected session
    //=====================================================
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print("connected to session \(session)")
            mainDelegate?.connectedWithPeer(peerID)
        } else if state == .connecting {
            print("connecting to session \(session)")
            DispatchQueue.main.async(execute: { 
                self.mainDelegate?.connectingWithPeer(peerID)
            })
        } else {
            print("could not connect to session \(session)")
            DispatchQueue.main.async(execute: { 
                self.mainDelegate?.couldNotConnectToSession()
            })
        }
    }
    
    // Received data from remote peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        print("I just recieved a \(NSString(data: data, encoding: String.Encoding.utf8.rawValue))")
        self.recievedData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        //let gameVC = GameViewController()
        //gameVC.determineWinner(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        gameViewDelegate?.received(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
    }
    
    
    // Received a byte stream from remote peer
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
    }
    
    // Start receiving a resource from remote peer
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?){
    }
    
    
    
    
    
    func sendData(_ string: String, toPeer targetPeer: MCPeerID) {
        let dataToSend = string.data(using: String.Encoding.utf8)
        let peersArray = NSArray(object: targetPeer)
        
        try! session.send(dataToSend!, toPeers: peersArray as! [MCPeerID], with: .unreliable)
    }
    
}