//
//  Enemy.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 12/06/24.
//

import Foundation
import GameplayKit

class Enemy: GKEntity {
    var name = ""
    var texture = SKTexture()
    let nodeSize = CGSize(width: 80, height: 80)
    var isActivated: Bool = false
    var isOnEdge: Int = 0
    
    init(name: String, health: Int, target: GKEntity) {
        self.name = name
        super.init()
//        Texture
        self.texture = SKTexture(imageNamed: name + "Node")
        
//        Sprite
        let spriteComponent = SpriteComponent(texture, size: nodeSize, zPos: 4)
        addComponent(spriteComponent)
        
//        Animation
        let animationComponent = AnimationComponent(name: name)
        addComponent(animationComponent)
        
//        Physics
        let physicComponent = PhysicComponent(SKPhysicsBody(rectangleOf: nodeSize), bitmask: PhysicsCategory.enemy, collision: PhysicsCategory.platform | PhysicsCategory.spike | PhysicsCategory.softPlatform, contact: (PhysicsCategory.player | PhysicsCategory.hitbox))
        addComponent(physicComponent)
        
        let chaseComponent = ChaseComponent(target: target)
        addComponent(chaseComponent)
        
        let combatComponent = CombatComponent(health)
        addComponent(combatComponent)
        
        let healthBarSize = CGSize(width: nodeSize.width, height: 10)
        let healthBarComponent = HealthBarComponent(size: healthBarSize, maxHealth: health, currentHealth: health)
        addComponent(healthBarComponent)
        
        let spriteNode = spriteComponent.node
        healthBarComponent.healthBar.position = CGPoint(x: 0, y: nodeSize.height / 2 + 10)
        spriteNode.addChild(healthBarComponent.healthBar)
        
        let noFallingComponent = NoFallingComponent(self)
        addComponent(noFallingComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
