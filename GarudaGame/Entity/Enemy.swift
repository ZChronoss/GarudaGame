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
    
    
    init(name: String, health: Int, target: GKEntity) {
        self.name = name
        super.init()
        
//        Texture
        self.texture = SKTexture(imageNamed: name + "Node")
        print(name)
        
//        Sprite
        let spriteComponent = SpriteComponent(texture, size: nodeSize, zPos: 4)
        addComponent(spriteComponent)
        
//        Animation
        let animationComponent = AnimationComponent(name: name)
        addComponent(animationComponent)
        
//        Physics
        let physicComponent = PhysicComponent(SKPhysicsBody(rectangleOf: nodeSize), bitmask: PhysicsCategory.enemy, collision: PhysicsCategory.platform, contact: (PhysicsCategory.player | PhysicsCategory.hitbox))
        addComponent(physicComponent)
        
        let chaseComponent = ChaseComponent(target: target)
        addComponent(chaseComponent)
        
        let combatComponent = CombatComponent(health)
        addComponent(combatComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
