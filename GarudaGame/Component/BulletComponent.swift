//
//  BulletComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 20/06/24.
//

import Foundation
import GameplayKit

class BulletComponent: GKComponent {
    let direction: CGVector!
    let node: SKSpriteNode!
    
    init(direction: CGVector!, node: SKSpriteNode) {
        self.direction = direction
        self.node = node
        
        let bulletPhysic = SKPhysicsBody(circleOfRadius: node.size.height)
        bulletPhysic.affectedByGravity = false
        bulletPhysic.restitution = 0
        bulletPhysic.isDynamic = true
        bulletPhysic.categoryBitMask = PhysicsCategory.bullet
        bulletPhysic.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.player
        bulletPhysic.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.platform
        node.physicsBody = bulletPhysic
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
