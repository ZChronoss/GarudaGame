//
//  NoFallingComponent.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 25/06/24.
//

import Foundation
import GameplayKit
import SpriteKit

class NoFallingComponent: GKComponent{
    init(_ enemy: Enemy) {
        super.init()
        let leftGroundHitbox = SKSpriteNode()
        leftGroundHitbox.size = CGSize(width: 10, height: 10)
        leftGroundHitbox.position.x = -35
        leftGroundHitbox.position.y = -50
        leftGroundHitbox.zPosition = 99
        let leftEnemyPhysics = SKPhysicsBody(rectangleOf: leftGroundHitbox.size)
        leftEnemyPhysics.categoryBitMask = PhysicsCategory.enemyGroundChecker
        leftEnemyPhysics.collisionBitMask = PhysicsCategory.none
        leftEnemyPhysics.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.softPlatform
        leftEnemyPhysics.affectedByGravity = false
        leftGroundHitbox.physicsBody = leftEnemyPhysics
        enemy.component(ofType: SpriteComponent.self)?.node.addChild(leftGroundHitbox)
        
        let rightGroundHitbox = SKSpriteNode()
        rightGroundHitbox.size = CGSize(width: 10, height: 10)
        rightGroundHitbox.position.x = 35
        rightGroundHitbox.position.y = -50
        rightGroundHitbox.zPosition = 99
        let rightEnemyPhysics = SKPhysicsBody(rectangleOf: rightGroundHitbox.size)
        rightEnemyPhysics.categoryBitMask = PhysicsCategory.enemyGroundChecker
        rightEnemyPhysics.collisionBitMask = PhysicsCategory.none
        rightEnemyPhysics.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.softPlatform
        rightEnemyPhysics.affectedByGravity = false
        rightGroundHitbox.physicsBody = rightEnemyPhysics
        enemy.component(ofType: SpriteComponent.self)?.node.addChild(rightGroundHitbox)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
