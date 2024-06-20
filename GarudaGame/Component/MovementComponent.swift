//
//  PlayerMovementComponent.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 14/06/24.
//

import Foundation
import GameplayKit

class MovementComponent: GKComponent {
    /// A convenience property for the entity's geometry component.
    var physicsBody: SKPhysicsBody? {
        return entity?.component(ofType: PhysicComponent.self)?.physicBody
    }
    
    var spriteNode: SKSpriteNode? {
        return entity?.component(ofType: SpriteComponent.self)?.node
    }
    
    /// Tells this entity's geometry component to jump.
    func jump() {
        let jumpVector = CGVector(dx: 0, dy: 180)
        physicsBody?.applyImpulse(jumpVector)
    }
    
    func move(playerVelocity: CGVector, joystickDisabled: Bool) {
        if joystickDisabled == false {
            spriteNode?.position.x += playerVelocity.dx
            spriteNode?.position.y += playerVelocity.dy
        }
    }
}
