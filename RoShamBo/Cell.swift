//
//  Cell.swift
//  RoShamBo
//
//  Created by Gaby Ecanow on 1/6/17.
//  Copyright © 2017 Gaby Ecanow. All rights reserved.
//

import UIKit

class Cell: UIButton {
    
    var number = 0
    var open = true
    
    convenience init(tag: Int) {
        self.init()
        number = tag
    }
    
}
