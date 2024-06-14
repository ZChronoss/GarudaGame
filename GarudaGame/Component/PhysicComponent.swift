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
    
    init(_ body: SKPhysicsBody) {
        self.physicBody = body
        physicBody.affectedByGravity = true
        physicBody.isDynamic = true
        physicBody.restitution = 0
        physicBody.allowsRotation = false
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
