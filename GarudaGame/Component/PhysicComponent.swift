//
//  PhysicComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit

class PhysicComponent: GKComponent {
    var physicBody: SKPhysicsBody
    
    init(_ body: SKPhysicsBody, bitmask: UInt32, collision: UInt32, contact: UInt32) {
        self.physicBody = body
        physicBody.affectedByGravity = true
        physicBody.isDynamic = true
        physicBody.restitution = 0
        physicBody.allowsRotation = false
        physicBody.categoryBitMask = bitmask
        physicBody.collisionBitMask = collision
        physicBody.contactTestBitMask = contact
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
