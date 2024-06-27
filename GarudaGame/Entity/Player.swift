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
    var isLongDashing = false
    var dashVelocity = CGVector.zero
    let dashDuration: CGFloat = 0.2
    var dashTimeElapsed: CGFloat = 0.0
    
    // Cooldown properties
    var dashCooldown = false
    let dashCooldownDuration: CGFloat = 1.0
    var dashCooldownTimeElapsed: CGFloat = 0.0
    
    var targetEnemies: [CGPoint] = []
    var playerFacing: Bool = true
    var health = 0
    
    let iFramesTime = 0.7
    var invincibility: Bool = false
    var isOnGround: Int = 0
    var isOnPlatform: Int = 0
    
    init(name: String, health: Int) {
        self.name = name
        self.health = health
        super.init()
        
//        Texture
        self.texture = SKTexture(imageNamed: name + "Node")
        
//        Sprite
        let spriteComponent = SpriteComponent(texture, size: nodeSize, zPos: 5)
        addComponent(spriteComponent)
        
//        Animation
        let animationComponent = AnimationComponent(name: name)
        addComponent(animationComponent)
        
//        Physics
        let playerPhysics = SKPhysicsBody(polygonFrom: UIBezierPath(roundedRect: CGRect(x: -nodeSize.width * 0.5, y: -nodeSize.height * 0.5, width: nodeSize.width, height: nodeSize.height), cornerRadius: 20).cgPath)
        let physicComponent = PhysicComponent(playerPhysics, bitmask: PhysicsCategory.player, collision: PhysicsCategory.platform | PhysicsCategory.spike , contact: PhysicsCategory.enemy | PhysicsCategory.spike | PhysicsCategory.platform)
        addComponent(physicComponent)
        
//        Movement
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        let combatComponent = CombatComponent(health)
        addComponent(combatComponent)
        
        let groundedComponent = GroundedComponent(self)
        addComponent(groundedComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
