//
//  isOnGroundChecker.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 24/06/24.
//

import Foundation
import GameplayKit
import SpriteKit

class GroundedComponent: GKComponent {
    init(_ player: Player) {
        super.init()
        let groundHitbox = SKSpriteNode()
        groundHitbox.size = CGSize(width: 64, height: 10)
        groundHitbox.color = .red
        groundHitbox.position.y = -50
        groundHitbox.zPosition = 99
        let groundedPhysicsbody = SKPhysicsBody(rectangleOf: groundHitbox.size)
        groundedPhysicsbody.categoryBitMask = PhysicsCategory.groundChecker
        groundedPhysicsbody.collisionBitMask = PhysicsCategory.none
        groundedPhysicsbody.contactTestBitMask = PhysicsCategory.platform
        groundedPhysicsbody.affectedByGravity = false
        groundHitbox.physicsBody = groundedPhysicsbody
        player.component(ofType: SpriteComponent.self)?.node.addChild(groundHitbox)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
