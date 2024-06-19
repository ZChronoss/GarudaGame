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
    var health: Int = 0
    
    init(name: String, health: Int) {
        self.name = name
        self.health = health
        super.init()
        
//        Texture
        self.texture = SKTexture(imageNamed: name + "Node")
        print(name)
        
//        Sprite
        let spriteComponent = SpriteComponent(texture, size: nodeSize)
        addComponent(spriteComponent)
        
//        Animation
        let animationComponent = AnimationComponent(name: name)
        addComponent(animationComponent)
        
//        Physics
        let physicComponent = PhysicComponent(SKPhysicsBody(rectangleOf: nodeSize), bitmask: 0x1 << 1, collision: 0x1 << 3, contact: 0x1 << 2)
        addComponent(physicComponent)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
