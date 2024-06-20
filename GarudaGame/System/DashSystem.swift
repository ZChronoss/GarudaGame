//
//  DashSystem.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 16/06/24.
//

import Foundation
import GameplayKit

class DashSystem: GKComponentSystem<MovementComponent>{
    private var lastUpdateTime: TimeInterval?
    
    func update(player: Player, currentTime: TimeInterval, joystick: JoystickView) {
        if player.isDashing {
            player.dashCooldown = true
            player.dashCooldownTimeElapsed = 0.0
            player.dashTimeElapsed += CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            if player.dashTimeElapsed < player.dashDuration {
                player.component(ofType: SpriteComponent.self)?.node.position.x += player.dashVelocity.dx * CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            } else {
                player.isDashing = false
                player.dashVelocity = CGVector.zero
                player.component(ofType: PhysicComponent.self)?.physicBody.affectedByGravity = true
                joystick.allowYControl = 0.0
            }
        }
        
        // Update dash cooldown
        if player.dashCooldown {
            player.dashCooldownTimeElapsed += CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            if player.dashCooldownTimeElapsed >= player.dashCooldownDuration {
                player.dashCooldown = false
            }
        }
        
        lastUpdateTime = currentTime
    }
    
    func dash(player:Player, dashSpeed: CGFloat) {
        if !player.dashCooldown{
            player.isDashing = true
            player.dashTimeElapsed = 0.0
            player.dashVelocity = player.playerFacing ? CGVector(dx: dashSpeed, dy: 0) : CGVector(dx: -dashSpeed, dy: 0)
        }
    }
    
    func playerFacing(player: Player, Velocity: CGVector){
        if Velocity.dx > 0 {
            player.playerFacing = true
        } else if Velocity.dx < 0 {
            player.playerFacing = false
        }
    }
    
    func longDash(player:Player, dashSpeed: CGFloat, joystick: JoystickView) {
        if !player.dashCooldown{
            player.component(ofType: PhysicComponent.self)?.physicBody.affectedByGravity = false
            joystick.allowYControl = 0.1
            player.isDashing = true
            player.dashTimeElapsed = -0.5
            player.dashVelocity = player.playerFacing ? CGVector(dx: dashSpeed, dy: 0) : CGVector(dx: -dashSpeed, dy: 0)
        }
    }
    
    func stopLongDash(player: Player) {
        player.dashTimeElapsed = 0.2
    }
    
    func targettedDash(player: Player, target: CGPoint){
        let move = SKAction.move(to: target, duration: 0.1)
        player.component(ofType: SpriteComponent.self)?.node.run(move)
    }
}
