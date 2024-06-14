//
//  LevelOneScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit
import SpriteKit

class LevelOneScene: BaseScene{
    var entityManager: EntityManager!
    var kecrek = Enemy(name: "Kecrek")
    var garuda = Enemy(name: "Garuda")
    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)
        
        if let spriteComponent = kecrek.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX + 30, y: frame.midY)
        }
        entityManager.addEntity(kecrek)
        entityManager.startAnimation(kecrek)
        entityManager.addPhysic(kecrek)
        
        if let spriteComponent = garuda.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX, y: frame.midY)
        }
        entityManager.addEntity(garuda)
        entityManager.startAnimation(garuda)
        entityManager.addPhysic(garuda)
        
        
        
        super.didMove(to: view)
        let platform = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 200))
        platform.fillColor = .brown
        platform.position = CGPoint(x: self.frame.midX, y: self.frame.minY)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.allowsRotation = false
        
        addChild(platform)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        garuda.component(ofType: SpriteComponent.self)?.node.position.x += playerVelocity.dx
        garuda.component(ofType: SpriteComponent.self)?.node.position.y += playerVelocity.dy
    }
}
