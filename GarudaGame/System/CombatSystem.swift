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
        let hitbox = SKSpriteNode(color: .clear, size: size)
        hitbox.position = position
        let hitboxBody = SKPhysicsBody(rectangleOf: hitbox.size)
        hitboxBody.categoryBitMask = PhysicsCategory.hitbox
        hitboxBody.collisionBitMask = PhysicsCategory.none
        hitboxBody.contactTestBitMask = PhysicsCategory.enemy
        hitboxBody.isDynamic = true
        hitboxBody.affectedByGravity = false
        hitboxBody.usesPreciseCollisionDetection = true
        hitbox.physicsBody = hitboxBody
        
        attacker.addChild(hitbox)
        
        let moveAction = SKAction.moveBy(x: 0, y: 0, duration: 0.05)
        let removeAction = SKAction.removeFromParent()
        hitbox.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func checkIfNodeInBetween(node1: SKSpriteNode?, node2: SKSpriteNode?) -> Bool {
        var nodesInBetween: [SKNode] = []
        if let rayStart = node1?.position, let rayEnd = node2?.position{
            if rayStart == rayEnd{
                return false
            }
            // Perform the raycast
            scene.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, normal, stop) in
                if let node = body.node {
                    // Ensure the node is not nodeA or nodeB
                    if node.physicsBody?.categoryBitMask == PhysicsCategory.platform || node.physicsBody?.categoryBitMask == PhysicsCategory.softPlatform {
                        nodesInBetween.append(node)
                        stop.pointee = true // Stop the enumeration if a node is found
                    }
                }
            }
            
        }
        
        return !nodesInBetween.isEmpty
    }
    
    func knockback(nodeA: SKSpriteNode?, knockup: CGFloat, knockback: CGFloat){
        let knockbackStrength: CGFloat = 80.0 // Adjust this value as needed
        let impulse = CGVector(dx: knockback * knockbackStrength, dy: abs(knockup * knockbackStrength))
        
        nodeA?.physicsBody?.applyImpulse(impulse)
    }
    
    func closestPoint(from points: [CGPoint], to target: CGPoint) -> CGPoint? {
        guard !points.isEmpty else { return nil }

        var closestPoint = points[0]
        var shortestDistance = distance(from: closestPoint, to: target)

        for point in points.dropFirst() {
            let currentDistance = distance(from: point, to: target)
            if currentDistance < shortestDistance {
                shortestDistance = currentDistance
                closestPoint = point
            }
        }

        return closestPoint
    }

    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    
}
