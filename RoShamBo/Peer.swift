//
//  Peer.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 10/25/16.
//  Copyright © 2016 Gaby Ecanow. All rights reserved.
//

import UIKit

class Peer: MCPeerID {
    
    var name = ""
    
    convenience init(name: String) {
        self.init()
        
        self.name = name
    }
    
}
