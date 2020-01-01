//
//  Move.swift
//  FourInARow2D
//
//  Created by slava bily on 3/10/19.
//  Copyright © 2019 slava bily. All rights reserved.
//

import GameplayKit
import UIKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var button: Int
    
    init(button: Int) {
        self.button = button
    }
}
