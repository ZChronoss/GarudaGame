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
    var garuda = Player(name: "Garuda")
    var dashSystem = DashSystem()
    
    var jumpCooldown = false
    let jumpCooldownDuration: TimeInterval = 0.5
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
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
        
        camera?.position = (garuda.component(ofType: SpriteComponent.self)?.node.position)!
        
        let platformNames = (1...7).map { "\($0)" }
        for name in platformNames {
            setupPlatform(name: name)
        }
    }
    
    func setupPlatform(name: String) {
        guard let platform = self.childNode(withName: name) as? SKShapeNode else {
            fatalError("Node with name \(name) not found or not a SKShapeNode")
        }
        
        print("Setting up platform: \(name)")
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.allowsRotation = false
    }
    
    func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Camera follows player with dampening effect
        let targetPosition = garuda.component(ofType: SpriteComponent.self)?.node.position
        let cameraPosition = cameraNode.position
        
        // Interpolate camera position towards player position
        let newX = lerp(a: cameraPosition.x, b: targetPosition!.x, t: 0.1) // Adjust t to control speed
        let newY = lerp(a: cameraPosition.y, b: targetPosition!.y, t: 0.1) // Adjust t to control speed
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        garuda.component(ofType: MovementComponent.self)?.move(playerVelocity: playerVelocity)
        dashSystem.playerFacing(player: garuda, Velocity: playerVelocity)
        dashSystem.update(player: garuda, currentTime: currentTime, joystick: joystick)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: cameraNode)
            
            if jumpButton.frame.contains(location) {
                if isOnGround() && !jumpCooldown {
                    garuda.component(ofType: MovementComponent.self)?.jump()
                    activateJumpCooldown()
                }
            }else if dashButton.frame.contains(location) {
                if !dashCooldown && isOnGround(){
                    dashSystem.dash(player: garuda, dashSpeed: 800.0)
                }else if !dashCooldown && !isOnGround() && !isDashing{
                    dashSystem.longDash(player: garuda, dashSpeed: 400.0, joystick: joystick)
                }else if !isOnGround() && isDashing{
                    dashSystem.stopLongDash(player: garuda)
                }
            }
        }
    }
    
    func activateJumpCooldown() {
        jumpCooldown = true
        Timer.scheduledTimer(withTimeInterval: jumpCooldownDuration, repeats: false) { _ in
            self.jumpCooldown = false
        }
    }
    
    func isOnGround() -> Bool {
        for platform in self.children {
            if let platformNode = platform as? SKShapeNode, platformNode.name != nil {
                if garuda.component(ofType: PhysicComponent.self)?.physicBody.allContactedBodies().contains(platformNode.physicsBody!) ?? false {
                    return true
                }
            }
        }
        return false
    }
    
}
