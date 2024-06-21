//
//  JumpSystem.swift
//  GarudaGame
//
//  Created by Leonardo Marhan on 17/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class CombatSystem: GKRuleSystem {
    var scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func spawnHitbox(attacker: SKSpriteNode, size: CGSize, position: CGPoint) {
        let hitbox = SKSpriteNode(color: .orange, size: size)
        hitbox.position = position
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
    
    func checkIfNodeInBetween(node1: SKSpriteNode?, node2: SKSpriteNode?) -> Bool {
        let rayStart = node1?.position
        let rayEnd = node2?.position
        
        var nodesInBetween: [SKNode] = []
        
        // Perform the raycast
        scene.physicsWorld.enumerateBodies(alongRayStart: rayStart ?? CGPointZero, end: rayEnd ?? CGPointZero) { (body, point, normal, stop) in
            if let node = body.node {
                // Ensure the node is not nodeA or nodeB
                if node.physicsBody?.categoryBitMask == PhysicsCategory.platform{
                        nodesInBetween.append(node)
                        stop.pointee = true // Stop the enumeration if a node is found
                }
            }
        }
        
        return !nodesInBetween.isEmpty
    }
    
    func knockback(nodeA: SKSpriteNode?, nodeB: SKSpriteNode?){
        // Calculate the direction of the knockback
        let knockbackVector = CGVector(dx: (nodeA?.position.x ?? 0) - (nodeB?.position.x ?? 0), dy: (nodeA?.position.y ?? 0) - (nodeB?.position.y ?? 0))
        
        // Normalize the knockback vector
        let length = sqrt(knockbackVector.dx * knockbackVector.dx + knockbackVector.dy * knockbackVector.dy)
        let normalizedVector = CGVector(dx: knockbackVector.dx / length, dy: knockbackVector.dy / length)
        
        // Apply the impulse to the garuda
        let knockbackStrength: CGFloat = 80.0 // Adjust this value as needed
        let impulse = CGVector(dx: normalizedVector.dx * knockbackStrength, dy: abs(normalizedVector.dy * knockbackStrength))
        
        nodeA?.physicsBody?.applyImpulse(impulse)
    }
}
