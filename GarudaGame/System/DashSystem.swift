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
    var scene: BaseScene?
    
    init(scene: SKScene) {
        self.scene = scene as? BaseScene
        super.init()
    }
    
    func update(player: Player, currentTime: TimeInterval, joystick: JoystickView) {
        if player.isDashing {
            player.dashCooldown = true
            player.dashCooldownTimeElapsed = 0.0
            player.dashTimeElapsed += CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            if player.dashTimeElapsed < player.dashDuration {
                player.component(ofType: SpriteComponent.self)?.node.position.x += player.dashVelocity.dx * CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            } else {
                player.isDashing = false
                scene?.slamIndicator.isHidden = true
                scene?.slamIndicator2.isHidden = true
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                    player.isLongDashing = false
                }
                player.dashVelocity = CGVector.zero
                player.component(ofType: PhysicComponent.self)?.physicBody.affectedByGravity = true
                joystick.allowYControl = 0.0
                joystick.allowXControl = 0.1
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
            player.component(ofType: PhysicComponent.self)?.physicBody.velocity = CGVector.zero
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
            let playerPhysics = player.component(ofType: PhysicComponent.self)?.physicBody
            playerPhysics?.velocity = CGVector.zero
            playerPhysics?.affectedByGravity = false
            joystick.allowYControl = 0.175
            joystick.allowXControl = 0.0
            player.isDashing = true
            player.isLongDashing = true
            player.dashTimeElapsed = -0.4
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
