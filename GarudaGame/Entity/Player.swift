//
//  Player.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 14/06/24.
//

import Foundation

import Foundation
import GameplayKit

class Player: GKEntity {
    var name = ""
    var texture = SKTexture()
    let nodeSize = CGSize(width: 80, height: 80)
    
    // Dash properties
    var isDashing = false
    var dashVelocity = CGVector.zero
    let dashDuration: CGFloat = 0.2
    var dashTimeElapsed: CGFloat = 0.0
    
    // Cooldown properties
    var dashCooldown = false
    let dashCooldownDuration: CGFloat = 1.0
    var dashCooldownTimeElapsed: CGFloat = 0.0
    
    var playerFacing: Bool = true
    
    init(name: String) {
        self.name = name
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
        let physicComponent = PhysicComponent(SKPhysicsBody(rectangleOf: nodeSize))
        addComponent(physicComponent)
        
//        Movement
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
