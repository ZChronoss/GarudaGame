//
//  JumpSystem.swift
//  GarudaGame
//
//  Created by Leonardo Marhan on 17/06/24.
//

import Foundation
import SpriteKit

class CombatSystem {
    func spawnHitbox(attacker: SKSpriteNode, directions: Bool) {
        let hitbox = SKSpriteNode(color: .orange, size: CGSize(width: 80, height: 60))
        hitbox.position = CGPoint(x: directions ? 50 : -50, y: 0)
        let hitboxBody = SKPhysicsBody(rectangleOf: hitbox.size)
        hitboxBody.categoryBitMask = PhysicsCategory.hitbox
        hitboxBody.collisionBitMask = PhysicsCategory.none
        hitboxBody.contactTestBitMask = PhysicsCategory.enemy
        hitboxBody.isDynamic = true
        hitboxBody.affectedByGravity = false
        hitbox.physicsBody = hitboxBody
        
        attacker.addChild(hitbox)
        
        let moveAction = SKAction.moveBy(x: 0, y: 0, duration: 0.05)
        let removeAction = SKAction.removeFromParent()
        hitbox.run(SKAction.sequence([moveAction, removeAction]))
    }
}
