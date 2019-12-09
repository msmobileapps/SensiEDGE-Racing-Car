//
//  Car.swift
//  sensiblecar
//
//  Created by Omer Cohen on 12/9/19.
//  Copyright © 2019 Omer Cohen. All rights reserved.
//

import UIKit
import SpriteKit

class Car: NSObject {
    var node:SKSpriteNode
    var status:Status
    
    enum Status{
        case left
        case center
        case right
    }
    override init(){
        self.node = SKSpriteNode()
        self.status = .center
    }
    
    func turnLeft(){
        switch self.status {
        case .right:
            self.status = .center
        default:
            self.status = .left
        }
    }
    
    func turnRight(){
        switch self.status {
        case .left:
            self.status = .center
        default:
            self.status = .right
        }
    }
}
